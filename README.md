# CSM Docs Publishing
This repo contains the build tools and templates necessary to transform markdown files in docs-csm to html for publication on Github pages.

## Getting Started
1. Make sure you have Docker and Docker Compose installed and access to checkout github.com:Cray-HPE/docs-csm.git.
1. Run `bin/build.sh`.  (This creates a public folder with the html.)
1. Run `bin/dev.sh` and view the result at http://localhost/docs-csm
1. If everything looks good, run `bin/push.sh` to push generated HTML to `release/docs-html` branch of `docs-csm` repo. This branch is set up to serve Github pages, accessible as <https://cray-hpe.github.io/docs-csm/>.

## TODO
1. Fix the remaining broken links.
1. Convert (or provide alternative to) shell scripts through native GitHhub mechanisms, such as workflow jobs and services. Shell scripts invoking direct `docker` or `docker-compose` commands may not be safe to execute on shared Github runners.
