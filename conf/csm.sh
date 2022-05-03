#
# MIT License
#
# (C) Copyright 2022 Hewlett Packard Enterprise Development LP
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
# Contains configuration variables for building csm docs.

# A list of releases that should be built. Each entry should be X.Y where the
# branch release/X.Y exists in the docs repo.
export BRANCHES=("0.9" "1.0" "1.2")

# The documentation repository remote URL. It must be possible to run
# 'git clone $DOCS_REPO_REMOTE_URL'.
export DOCS_REPO_REMOTE_URL="git@github.com:Cray-HPE/docs-csm.git"

# The name of the log file.
export LOG_FILE="csm_docs_build.log"

# The local directory to which the documentation repository should be cloned.
export DOCS_REPO_LOCAL_DIR="docs-csm"

# The title that should appear at the top of the HTML docs.
export DOC_TITLE="CSM Documentation"

# The branch to which the HTML docs should be pushed.
export DOCS_HTML_RELEASE_BRANCH="release/docs-html"

# The path to the docker-compose YAML file that should be used for Hugo prep
# (relative to the compose/ directory).
export HUGO_PREP_COMPOSE_FILE="hugo_prep.yml"

# The path to the docker-compose YAML File that should be used for Hugo build
# (relative to the compose/ directory).
export HUGO_BUILD_COMPOSE_FILE="hugo_build.yml"

# The path to the docker-compose YAML file that should be used for Hugo tests.
# (relative to the compose/ directory).
export HUGO_TEST_COMPOSE_FILE="test.yml"

# The path to the docker-compose YAML file that should be used for the Hugo
# local development server (relative to the compose/ directory).
export HUGO_DEV_SERVER_COMPOSE_FILE="dev_serve.yml"

# The names of the "linkcheck" services in $HUGO_TEST_COMPOSE_FILE
export LINKCHECK_SERVICE_NAMES=("linkcheck_en_09" "linkcheck_en_10" "linkcheck_en_11" "linkcheck_en_12")

# The name of the "index" files that should be converted to _index.md files in
# convert-docs-to-hugo.sh
export INDEX_FILE_NAME="index.md"
