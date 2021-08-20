#!/usr/bin/env bash
set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $THIS_DIR/lib/*
cd $THIS_DIR/..

docker-compose -f $THIS_DIR/compose/test.yml up \
    --force-recreate --no-color --remove-orphans serve_static

