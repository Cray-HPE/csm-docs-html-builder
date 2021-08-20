# CSM Docs Publishing
This repo contains the build tools and templates necessary to transform markdown files in docs-csm to html for publication on Github pages.

## Getting Started
1. Make sure you have Docker and Docker Compose installed and access to checkout github.com:Cray-HPE/docs-csm.git.
1. Run `bin/build.sh`.  (This creates a public folder with the html.)
1. Run `bin/dev.sh` and view the result at http://localhost/csm

## TODO
1. Fix the remaining broken links.
1. Integrate with a CI job.
