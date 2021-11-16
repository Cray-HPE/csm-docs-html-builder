#!/usr/bin/env bash

set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
mkdir -p docs-csm
cd docs-csm
git clone --depth=1 -b release/docs-html git@github.com:Cray-HPE/docs-csm.git
cd ..
rm -rf docs-csm/docs-csm/* docs-csm/docs-csm/.github docs-csm/docs-csm/.gitignore docs-csm/docs-csm/.version
cp -r public/* docs-csm/docs-csm/
cd docs-csm/docs-csm
git add .
git commit -m "Generated HTML from docs-csm"
git push origin release/docs-html
