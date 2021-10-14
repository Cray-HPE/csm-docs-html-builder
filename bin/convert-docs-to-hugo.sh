#!/usr/bin/env bash
set -e
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $THIS_DIR/lib/*

function help() {
    cat <<-MSG
Description:
This script recursively copies and transforms markdown files from a source directory into a destination
directory for use by the Hugo static website engine. It expects two named arguments where --source is
the path to the docs-csm repo and --destination is the path to the hugo content folder.  The content
folder will be deleted and recreated.

This script also looks for an environment variable named CSM_BRANCH in order to place content in the
appropriate subdirectory which maps to a Hugo "language".

Example:
./convert-docs-to-hugo.sh --source [path to docs-csm] --destination [path to hugo content]

MSG
exit 1
}

function validate_args() {
    [[ $1 != "--source" ]] && help

    # Validate source directory
    [[ ! -d $2 ]] && help
    if [[ ! -d $2/$CSM_BRANCH ]]; then
        echo "Expected --source to point to the docs-csm repo.  Didn't find $CSM_BRANCH directory."
        help
    fi

    [[ $3 != "--destination" ]] && help

    # Validate destination directory
    [[ ! -d $4 ]] && help
    if [[ $(basename $4) != "content" ]]; then
        echo "Expected --destination to point to the hugo content directory."
        help
    fi

    if [[ -z $CSM_BRANCH ]]; then
        echo "Expected a CSM_BRANCH environment variable."
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
    if [[ -z $newtitle ]]; then
        echo $1
        echo "Old Title: $oldtitle"
        echo "No title found"
        exit 1
    fi
    filename=$(basename $1)
    mid_path=$(echo -n $1 | sed "s|${SOURCE_DIR}||" | sed "s|${filename}||")
    [[ $filename == "index.md" ]] && filename="_index.md"
    destination_file="${DESTINATION_DIR}/${mid_path}/${filename}"
    echo -n "New Title: ${newtitle} - Transforming ${1} into ${destination_file}...  "

    # Add the yaml metadata to the top of the new file
    gen_hugo_yaml "$newtitle" > $destination_file

    # Add the file content.
    transform_links $1 >> $destination_file
    echo "done."
}

function get_old_title() {
    # Look for a header1 tag in the first 10 lines of the file.
    cat $1 | head -10 | grep -E "^#+\s" | head -1
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

function apply_specific_fixes() {
    [[ $CSM_BRANCH != "0.9" ]] && mv $DESTINATION_DIR/upgrade/1.0/README.md $DESTINATION_DIR/upgrade/1.0/_index.md
    mv $DESTINATION_DIR/upgrade/0.9/csm-0.9.4/README.md $DESTINATION_DIR/upgrade/0.9/csm-0.9.4/_index.md
}

function delete_dir_contents() {
    [[ -d $1 ]] && rm -rf $1
    mkdir -p $1
}

validate_args $1 $2 $3 $4
SOURCE_DIR=$(cd $2 && pwd)
SOURCE_DIR=${SOURCE_DIR}/${CSM_BRANCH}

DESTINATION_DIR=$(cd $4 && pwd)
DESTINATION_DIR="${DESTINATION_DIR}/${CSM_BRANCH}"
delete_dir_contents $DESTINATION_DIR

crawl_directory $SOURCE_DIR
populate_missing_index_files
apply_specific_fixes
