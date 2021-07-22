#!/usr/bin/env bash
set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ -z $1 ]]; then
  echo "Please specify a branch to checkout, e.g. 'bin/build.sh release/1.0'"
  exit 1
fi

cd $THIS_DIR/..
mkdir -p ./content

echo "Cloning into docs-csm..."
rm -rf docs-csm
git clone git@github.com:Cray-HPE/docs-csm.git
response=$(cd ./docs-csm && git checkout "$1")
echo $response

echo "Making markdown files friendly to Hugo..."
docker-compose run hugo_prep

cd $OLDPWD
