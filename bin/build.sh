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
BRANCHES=(0.9 1.0 1.1 1.2)

function clean() {
  function clean_dir() {
    [[ -d ./$1 ]] && sudo rm -rf ./$1
    mkdir -p ./$1
  }
  clean_dir content
  clean_dir public
  clean_dir docs-csm
  [[ -f csm_docs_build.log ]] && rm csm_docs_build.log
  touch csm_docs_build.log
  docker network prune -f
}
clean

function build () {
  echo "Cloning into docs-csm..."

  mkdir -p ./docs-csm
  cd ./docs-csm
  for branch in ${BRANCHES[@]}; do
    git clone --depth 1 -b release/$branch git@github.com:Cray-HPE/docs-csm.git ./$branch
  done
  cd ${OLDPWD}

  echo "Preparing markdown for Hugo..."
  docker-compose -f $THIS_DIR/compose/hugo_prep.yml up \
    --force-recreate --no-color --remove-orphans | \
  tee -a csm_docs_build.log
  docker-compose -f $THIS_DIR/compose/hugo_prep.yml down

  echo "Creating root _index.md"
  gen_hugo_yaml "CSM Documentation" > content/_index.md
  gen_index_header "CSM Documentation" >> content/_index.md
  gen_index_content content $relative_path >> content/_index.md

  echo "Build html pages with Hugo..."
  docker-compose -f $THIS_DIR/compose/hugo_build.yml up \
    --force-recreate --no-color --remove-orphans --abort-on-container-exit | \
  tee -a csm_docs_build.log
  docker-compose -f $THIS_DIR/compose/hugo_build.yml down
}
build

function test_links() {
  echo "Build html pages with Hugo..."

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
