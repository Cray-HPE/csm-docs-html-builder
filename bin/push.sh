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
# Script to copy from public/ to the docs repo, and then push the
# release/docs-html branch.
#
set -ex
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$THIS_DIR/.."

# Default product is CSM to maintain backward compatibility
PRODUCT_NAME=${1:-csm}
# shellcheck source=conf/csm.sh
source "${THIS_DIR}/../conf/${PRODUCT_NAME}.sh"

# This directory may already exist as it is used by build.sh
mkdir -p "$DOCS_REPO_LOCAL_DIR"
# Create an inner directory of the same name (e.g. docs-csm/docs-csmXXX/) to
# commit changes, where XXX are 3 random characters. Use random characters so
# that this script can be run multiple times without needing to remove the
# directory each time.
DOCS_LOCAL_PUSH_DIR=$(mktemp -d "${DOCS_REPO_LOCAL_DIR}/${DOCS_REPO_LOCAL_DIR}XXX")
# Clone with --no-checkout so that no extraneous files/directories (e.g.
# .version, .gitignore, .github) are checked out.
git clone \
  --no-checkout \
  --depth=1 \
  --branch="$DOCS_HTML_RELEASE_BRANCH" \
  "$DOCS_REPO_REMOTE_URL" \
  "$DOCS_LOCAL_PUSH_DIR"

# Add and commit the changes from public/, then push the branch.
cp -r public/* "$DOCS_LOCAL_PUSH_DIR"
cd "$DOCS_LOCAL_PUSH_DIR"
git add .
pwd
git commit -m "Generated HTML from $DOCS_REPO_LOCAL_DIR"
git push origin "$DOCS_HTML_RELEASE_BRANCH"
