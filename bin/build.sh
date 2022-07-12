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
set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $THIS_DIR/lib/*
cd $THIS_DIR/..
LAST_DIR=${OLDPWD}

# Default product is CSM to maintain backward compatibility
PRODUCT_NAME=${1:-csm}
# shellcheck source=conf/csm.sh
source "${THIS_DIR}/../conf/${PRODUCT_NAME}.sh"

function clean() {
  function clean_dir() {
    [[ -d ./$1 ]] && sudo rm -rf ./$1
    mkdir -p ./$1
  }
  clean_dir content
  clean_dir public
  # DOCS_REPO_LOCAL_DIR should be set in $PRODUCT_NAME.sh, but give
  # it a default so that it doesn't call `sudo rm -rf .` when the
  # variable is unset.
  clean_dir "${DOCS_REPO_LOCAL_DIR:-docs-csm}"
  [[ -f $LOG_FILE ]] && rm "$LOG_FILE"
  touch "$LOG_FILE"
  docker network prune -f
}
clean

function build () {
  echo "Cloning into ${DOCS_REPO_LOCAL_DIR}..."

  mkdir -p "$DOCS_REPO_LOCAL_DIR"
  cd "$DOCS_REPO_LOCAL_DIR"
  for branch in "${BRANCHES[@]}"; do
    git clone --depth 1 -b "release/${branch}" "$DOCS_REPO_REMOTE_URL" "./${branch}"
  done
  cd ${OLDPWD}

  echo "Preparing markdown for Hugo..."
  set +e
  docker-compose -f "${THIS_DIR}/compose/${HUGO_PREP_COMPOSE_FILE}" up \
    --force-recreate --no-color --remove-orphans | \
  tee -a "$LOG_FILE"
  exit_code=${PIPESTATUS[0]}
  docker-compose -f "${THIS_DIR}/compose/${HUGO_PREP_COMPOSE_FILE}" down
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
  set +e
  docker-compose -f "$THIS_DIR/compose/${HUGO_BUILD_COMPOSE_FILE}" up \
    --force-recreate --no-color --remove-orphans --abort-on-container-exit --exit-code-from hugo_build | \
  tee -a "$LOG_FILE"
  exit_code=${PIPESTATUS[0]}
  docker-compose -f "$THIS_DIR/compose/${HUGO_BUILD_COMPOSE_FILE}" down
  set -e
  return ${exit_code}
}
build

cd $LAST_DIR
