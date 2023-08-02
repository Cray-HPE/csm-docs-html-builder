#
# MIT License
#
# (C) Copyright 2022-2023 Hewlett Packard Enterprise Development LP
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
# Contains configuration variables for building sat docs.
#

# A list of releases that should be built. Each entry should be X.Y where the
# branch release/X.Y exists in the docs repo.
export BRANCHES=("2.6" "2.5" "2.4" "2.3" "2.2" "2.1")

# The documentation repository remote URL. It must be possible to run
# 'git clone $DOCS_REPO_REMOTE_URL'.
export DOCS_REPO_REMOTE_URL="git@github.com:Cray-HPE/docs-sat.git"

# The local directory to which the documentation repository should be cloned.
export DOCS_REPO_LOCAL_DIR="docs-sat"

# The title that should appear at the top of the HTML docs.
export DOC_TITLE="SAT Documentation"

# The branch to which the HTML docs should be pushed.
export DOCS_HTML_RELEASE_BRANCH="publish/docs-html"

# Hugo config file template, relative to repo root. Resulting file will be generated from this
# template by replacing ${BRANCH} for each branch name and merging results into single file.
export HUGO_CONFIG_FILE_TEMPLATE=config.sat.yaml

# The name of the "index" files that should be converted to _index.md files in
# convert-docs-to-hugo.sh
export INDEX_FILE_NAME="README.md"

# The name of a directory (relative to the top level of the repository)
# containing the documentation source. If this is not set, then the scripts
# will assume the top level of the repository is the top level of the
# documentation.
export SOURCE_SUBDIR="docs"
