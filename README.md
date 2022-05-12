# CSM Docs Publishing
This repo contains the build tools and templates necessary to transform markdown files in docs-csm to html for publication on Github pages.

## Getting Started
1. Make sure you have Docker and Docker Compose installed and access to checkout github.com:Cray-HPE/docs-csm.git.
1. Run `bin/build.sh`.  (This creates a public folder with the html.)
1. Run `bin/dev.sh` and view the result at http://localhost/csm

## Building SAT docs
You can build SAT docs using the same scripts as the CSM docs use.
1. Make sure you have Docker and Docker Compose installed and access to checkout the SAT docs repo (see conf/sat.sh)
1. Run `bin/build.sh sat`.
1. Run `bin/dev.sh sat` and view the result at http://localhost/docs-sat

## TODO
1. Fix the remaining broken links.
1. Integrate with a CI job.
