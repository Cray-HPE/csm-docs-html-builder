#!/usr/bin/env bash
#
# MIT License
#
# (C) Copyright 2021-2022 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
set -e
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $THIS_DIR/lib/content_prep
source $THIS_DIR/lib/functions.sh
cd $THIS_DIR/..
LAST_DIR=${OLDPWD}
TMP_DIR="$(mktemp -d)"
export TMP_DIR
trap "docker-compose -f ${TMP_DIR}/hugo_prep.yml down; rm -Rf ${TMP_DIR}; docker-compose -f ${THIS_DIR}/compose/hugo_build.yml down" EXIT

# Default product is CSM to maintain backward compatibility
PRODUCT_NAME=${1:-csm}
# shellcheck source=conf/csm.sh
source "${THIS_DIR}/../conf/${PRODUCT_NAME}.sh"

function clean() {
  function clean_dir() {
    [[ -d ./$1 ]] && rm -rf ./$1
    mkdir -p ./$1
  }
  clean_dir content
  clean_dir public
  docker network prune -f
}
clean

function build () {
  echo "Cloning into ${DOCS_DIR}..."

  mkdir -p "$DOCS_DIR"
  cd "$DOCS_DIR"
  for branch in "${BRANCHES[@]}"; do
      if [ -d "./${branch}" ]; then
          git -C "./${branch}" checkout -B "release/${branch}"
          git -C "./${branch}" pull origin "release/${branch}"
      else
          git clone --depth 1 -b "release/${branch}" "$DOCS_REPO_REMOTE_URL" "./${branch}"
      fi
  done
  cd "${OLDPWD}"

  echo "Preparing markdown for Hugo..."
  generate_yaml "${THIS_DIR}/compose/hugo_prep.yml" "${TMP_DIR}/hugo_prep.yml"
  set +e
  docker-compose -f "${TMP_DIR}/hugo_prep.yml" up --force-recreate --no-color --remove-orphans | tee "${TMP_DIR}/hugo_prep.log"
  exit_code=${PIPESTATUS[0]}
  if [ $exit_code -eq 0 ]; then
      if grep -E 'hugo_prep_[0-9]+ exited with code' "${TMP_DIR}/hugo_prep.log" | grep -v 'exited with code 0'; then 
          exit_code=1
      fi
  fi
  set -e
  if [ $exit_code -ne 0 ]; then
    echo "Exiting due to Hugo preparation errors above ..."
    exit $exit_code
  fi

  echo "Creating root _index.md"
  gen_hugo_yaml "$DOC_TITLE" > content/_index.md
  gen_index_header "$DOC_TITLE" >> content/_index.md
  gen_index_content content >> content/_index.md

  echo "Build html pages with Hugo..."
  generate_yaml "${THIS_DIR}/../hugo.yaml" "${TMP_DIR}/hugo.yaml"
  docker-compose -f "$THIS_DIR/compose/hugo_build.yml" up \
    --force-recreate --remove-orphans --abort-on-container-exit --exit-code-from hugo_build
}
build

cd $LAST_DIR
