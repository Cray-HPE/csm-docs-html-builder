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
set -e
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $THIS_DIR/lib/*

# Default product is CSM to maintain backward compatibility
PRODUCT_NAME=${PRODUCT_NAME:-csm}
# shellcheck source=conf/csm.sh
source "${THIS_DIR}/../conf/${PRODUCT_NAME}.sh"


function help() {
    cat <<-MSG
Description:
This script recursively copies and transforms markdown files from a source directory into a destination
directory for use by the Hugo static website engine. It expects two named arguments where --source is
the path to the docs-csm repo and --destination is the path to the hugo content folder.  The content
folder will be deleted and recreated.

This script also looks for an environment variable named DOCS_BRANCH in order to place content in the
appropriate subdirectory which maps to a Hugo "language". 

To build products other than CSM, set the PRODUCT_NAME environment variable.

Example:
./convert-docs-to-hugo.sh --source [path to docs-csm] --destination [path to hugo content]

MSG
exit 1
}

function validate_args() {
    [[ $1 != "--source" ]] && help

    # Validate source directory
    [[ ! -d $2 ]] && help
    if [[ ! -d $2/$DOCS_BRANCH ]]; then
        echo "Expected --source to point to the docs-csm repo.  Didn't find $DOCS_BRANCH directory."
        help
    fi

    [[ $3 != "--destination" ]] && help

    # Validate destination directory
    [[ ! -d $4 ]] && help
    if [[ $(basename $4) != "content" ]]; then
        echo "Expected --destination to point to the hugo content directory."
        help
    fi

    if [[ -z $DOCS_BRANCH ]]; then
        echo "Expected a DOCS_BRANCH environment variable."
        help
    fi
}

function crawl_directory() {
    for file in $(ls "$1")
    do
        if [[ -f ${1}/${file} ]]; then
            if [[ "${file: -3}" == ".md" ]]; then
                process_file $1/$file
            else
                echo "${1}/${file} is not a markdown file. Copying as is..."
                mid_path=$(echo -n "${1}/${file}" | sed "s|${SOURCE_DIR}||" | sed "s|${file}||")
                cp ${1}/${file} $DESTINATION_DIR/$mid_path/
            fi
        else
            echo "Crawling subdirectory ${1}/${file}"
            mid_path=$(echo -n "${1}/${file}" | sed "s|${SOURCE_DIR}||")
            mkdir -p $DESTINATION_DIR/$mid_path
            crawl_directory ${1}/${file}
        fi
    done
}

function process_file() {
    oldtitle=$(get_old_title $1)
    newtitle=$(make_new_title "${oldtitle}")
    # Exiting with code 1 here does not throw error - just stops processing half way done
    # if [[ -z $newtitle ]]; then
    #     echo $1
    #     echo "Old Title: $oldtitle"
    #     echo "No title found"
    #     exit 1
    # fi
    filename=$(basename $1)
    mid_path=$(echo -n $1 | sed "s|${SOURCE_DIR}||" | sed "s|${filename}||")
    [[ $filename == "${INDEX_FILE_NAME:-index.md}" ]] && filename="_index.md"
    destination_file="${DESTINATION_DIR}/${mid_path}/${filename}"
    # echo -n "New Title: ${newtitle} - Transforming ${1} into ${destination_file}...  "

    # Add the yaml metadata to the top of the new file
    gen_hugo_yaml "$newtitle" > $destination_file

    # Add the file content.
    transform_links $1 "$INDEX_FILE_NAME" >> $destination_file
    # echo "done."
}

function get_old_title() {
    # Look for a header1 tag in the first 10 lines of the file.
    cat $1 | head -10 | grep -E "^(#+\s|<h1)" | head -1 | sed -e 's|<h1[^>]*>||' | sed -e 's|</h1>||'
}

function populate_missing_index_files() {
    echo "####### Populating Missing Index Files #########"
    for dir in $(find $DESTINATION_DIR -type d)
    do
        relative_path=$(echo -n $dir | sed "s|${DESTINATION_DIR}||")
        if [[ ! -f $dir/_index.md ]] && \
            [[ -z $(echo $relative_path | grep "img") ]] && \
            [[ -z $(echo $relative_path | grep "scripts") ]]; then
            new_title=$(make_new_title "$(basename $dir)")
            echo "Title: ${new_title} - Creating missing index file at $dir/_index.md"
            gen_hugo_yaml "$new_title" > $dir/_index.md
            gen_index_header "$new_title" >> $dir/_index.md
            gen_index_content $dir $relative_path >> $dir/_index.md
        fi
    done
}

function apply_specific_csm_fixes() {
    set +e
    [[ $DOCS_BRANCH != "0.9" ]] && mv $DESTINATION_DIR/upgrade/1.0/README.md $DESTINATION_DIR/upgrade/1.0/_index.md
    mv $DESTINATION_DIR/upgrade/0.9/csm-0.9.4/README.md $DESTINATION_DIR/upgrade/0.9/csm-0.9.4/_index.md
    set -e
}

function delete_dir_contents() {
    [[ -d $1 ]] && rm -rf $1
    mkdir -p $1
}

validate_args $1 $2 $3 $4
SOURCE_DIR=$(cd $2 && pwd)
SOURCE_DIR=${SOURCE_DIR}/${DOCS_BRANCH}
if  [[ -n "$SOURCE_SUBDIR" ]]; then
  SOURCE_DIR="${SOURCE_DIR}/${SOURCE_SUBDIR}"
fi

DESTINATION_DIR=$(cd $4 && pwd)
DESTINATION_DIR="${DESTINATION_DIR}/${DOCS_BRANCH}"
delete_dir_contents $DESTINATION_DIR

crawl_directory $SOURCE_DIR
populate_missing_index_files
if [[ "$PRODUCT_NAME" == "csm" ]]; then
    apply_specific_csm_fixes
fi
