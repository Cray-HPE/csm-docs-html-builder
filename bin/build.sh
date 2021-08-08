#!/usr/bin/env bash
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

  for branch in ${BRANCHES[@]}; do
    mkdir -p ./docs-csm/tmp
    cd ./docs-csm/tmp
    BACK_DIR=${OLDPWD}
    git clone git@github.com:Cray-HPE/docs-csm.git
    mv docs-csm ../$branch
    cd ../$branch
    git fetch
    git checkout "release/$branch" && git pull origin "release/$branch"
    cd $BACK_DIR
    sudo rm -rf docs-csm/tmp
  done

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
