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
cd $THIS_DIR/..
LAST_DIR=${OLDPWD}
TMP_DIR="$(mktemp -d)"
export TMP_DIR
trap "docker-compose -f ${TMP_DIR}/hugo_test.yaml down; rm -Rf ${TMP_DIR}" EXIT

# Default product is CSM to maintain backward compatibility
PRODUCT_NAME=${1:-csm}
# shellcheck source=conf/csm.sh
source "${THIS_DIR}/../conf/${PRODUCT_NAME}.sh"
source $THIS_DIR/lib/functions.sh

function test_links() {
  echo "Test links in HTML pages..."
  generate_yaml "${THIS_DIR}/compose/test.yml" "${TMP_DIR}/hugo_test.yaml"

  # Standup the nginx server as a background daemon first
  docker-compose -f "${TMP_DIR}/hugo_test.yaml" up --force-recreate --remove-orphans -d serve_static

  SERVICE_NAMES=( $(for BRANCH in "${BRANCHES[@]}"; do echo linkcheck_en_${BRANCH//./}; done) )
  # Crawl the links for each version
  docker-compose -f "${TMP_DIR}/hugo_test.yaml" up --force-recreate --remove-orphans "${SERVICE_NAMES[@]}"
}
test_links

cd $LAST_DIR
