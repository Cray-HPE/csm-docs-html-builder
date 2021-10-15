#!/usr/bin/env bash

set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
mkdir -p docs-csm
cd docs-csm
git clone git@github.com:Cray-HPE/docs-csm.git
cd docs-csm
git_sha=$(git log -1 --format=%h)
git checkout -b release/docs-html -t origin/release/docs-html || git checkout --orphan release/docs-html
cd ../..
rm -rf docs-csm/docs-csm/* docs-csm/docs-csm/.github docs-csm/docs-csm/.gitignore docs-csm/docs-csm/.version
cp -r csm-docs-html-builder/public/* docs-csm/docs-csm/
cd docs-csm/docs-csm
git add .
git commit -m "Generated HTML from docs-csm revision ${git_sha}"
git push origin release/docs-html
