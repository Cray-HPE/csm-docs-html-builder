# CSM Docs Publishing
This repo contains the build tools and templates necessary to transform markdown files in docs-csm to html for publication on Github pages.

## Getting Started
1. Make sure you have Docker and Docker Compose installed and access to checkout github.com:Cray-HPE/docs-csm.git.
1. Run `bin/build.sh`.  (This a public folder with the html.)
1. Run `docker-compose run serve_static`
1. View the result at http://localhost:8080

## TODO
1. Add a link checker and fix the remaining broken links.
1. Integrate with a CI job.
