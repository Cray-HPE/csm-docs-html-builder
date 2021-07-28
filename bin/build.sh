#!/usr/bin/env bash
set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BRANCHES=(0.9 1.0 1.1 1.2)

cd $THIS_DIR/..
[[ -d ./content ]] && rm -rf ./content
mkdir -p ./content

echo "Cloning into docs-csm..."
rm -rf docs-csm
git clone git@github.com:Cray-HPE/docs-csm.git
$(cd ./docs-csm && git fetch)

for branch in ${BRANCHES[@]}; do
  response=$(cd ./docs-csm && git checkout "release/$branch" && git pull origin "release/$branch")
  echo $response

  echo "Making markdown files friendly to Hugo..."
  docker-compose run -e CSM_BRANCH=$branch hugo_prep
done

cd $OLDPWD
