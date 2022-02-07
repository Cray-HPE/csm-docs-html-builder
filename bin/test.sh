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
cd $THIS_DIR/..
LAST_DIR=${OLDPWD}

function test_links() {
  echo "Test links in HTML pages..."

  # Standup the nginx server as a background daemon first
  docker-compose -f $THIS_DIR/compose/test.yml up --force-recreate --no-color --remove-orphans -d serve_static

  # Crawl the links for each version
  docker-compose -f $THIS_DIR/compose/test.yml up --no-color --remove-orphans \
  linkcheck_en_09 linkcheck_en_10 linkcheck_en_11 linkcheck_en_12 | tee -a csm_docs_build.log

  # Tear it all down
  docker-compose -f $THIS_DIR/compose/test.yml down
}
test_links

cd $LAST_DIR
