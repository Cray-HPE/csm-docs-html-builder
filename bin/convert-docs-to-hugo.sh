#!/usr/bin/env bash
set -e

function help() {
    cat <<-MSG
Description:
This script recursively copies and transforms markdown files from a source directory into a destination
directory for use by the Hugo static website engine. It expects two named arguments where --source is 
the path to the docs-csm repo and --destination is the path to the hugo content folder.  The content 
folder will be deleted and recreated.

Example: 
./convert-docs-to-hugo.sh --source [path to docs-csm] --destination [path to hugo content]

MSG
exit 1
}

function validate_args() {
    [[ $1 != "--source" ]] && help

    # Validate source directory
    [[ ! -d $2 ]] && help
    if [[ ! -f $2/docs-csm-install.spec ]]; then
        echo "Expected --source to point to the docs-csm repo.  Didn't find docs-csm-install.spec file."
        exit 1
    fi

    [[ $3 != "--destination" ]] && help

    # Validate destination directory
    [[ ! -d $4 ]] && help
    if [[ $(basename $4) != "content" ]]; then
        echo "Expected --destination to point to the hugo content directory."
        exit 1
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
    echo "New Title: ${newtitle}"
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
    echo -n "Transforming ${1} into ${destination_file}...  "

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

function make_new_title() {
    # Remove "CSM", extra spaces, number signs, html, and colons.
    # Change underscores to spaces. Capitalize acronyms and every word.
    echo "${1}" | \
    sed -r 's`^#+ ``' | \
    sed -r 's`CSM``' | sed 's`csm``g' | sed 's`()``g' | \
    sed -r 's`^ +``' | \
    sed 's`:``g' | \
    sed 's`_` `g' | \
    sed -r 's`<.*>.*<.*>``' | \
    sed 's`\\(`(`g' | sed 's`\\)`)`g' | \
    awk '{for (i=1; i<=NF; ++i) { $i=toupper(substr($i,1,1)) tolower(substr($i,2)); } print }' | \
    sed -r 's`[S,s]ls`SLS`' | \
    sed -r 's`[T,s]ls`TLS`' | \
    sed -r 's`[P,p]ki`PKI`' | \
    sed -r 's`[S,s]sh`SSH`' | \
    sed -r 's`[U,u]an`UAN`' | \
    sed -r 's`[U,u]ai`UAI`' | \
    sed -r 's`[U,u]as`UAS`' | \
    sed -r 's`[B,b]mc`BMC`' | \
    sed -r 's`[H,h]ttps`HTTPS`' | \
    sed -r 's`[H,h]ttp`HTTP`' | \
    sed -r 's`[L,l]dap`LDAP`' | \
    sed -r 's`[R,r]eds`REDS`' | \
    sed -r 's`[M,m]eds`MEDS`' | \
    sed -r 's`[N,n]tp`NTP`' | \
    sed -r 's`[C,c]apmc`CAPMC`' | \
    sed -r 's`[K,k]vm`KVM`' | \
    sed -r 's`[G,g]pu`GPU`' | \
    sed -r 's`[H,h]sn`HSN`' | \
    sed -r 's`[H,h]sm`HSM`' | \
    sed -r 's`[N,n]ic`NIC`' | \
    sed -r 's`[N,n]cn`NCN`' | \
    sed -r 's`[B,b]gp`BGP`' | \
    sed -r 's`[D,d]ns`DNS`' | \
    sed -r 's`[D,d]hcp`DHCP`' | \
    sed -r 's`[H,h]pe`HPE`' | \
    sed -r 's`[I,i]ms`IMS`' | \
    sed -r 's`[F,f]as`FAS`' | \
    sed -r 's`[C,c]fs`CFS`' | \
    sed -r 's`[B,b]os`BOS`' | \
    sed -r 's`[C,c]rus`CRUS`' | \
    sed -r 's`[C,c]an`CAN`' | \
    sed -r 's`[P,p]xe`PXE`' | \
    sed -r 's`[A,a]cl`ACL`'
}

function transform_links() {
    # Remove .md suffixes from links.  TODO: lowercase links
    cat $1 | sed -r 's|\((.*).md\)|\(\1\)|g'
}

function gen_hugo_yaml() {
    cat <<-YAML
---
title: $1
date: $(date)
draft: false
---
YAML
}

function gen_index_header() {
    cat <<-YAML
# $1
Topics:
YAML
}

function gen_index_content() {
    # e.g. 1. [Prepare Configuration Payload](install/prepare_configuration_payload.md)
    for f in $(ls $1)
    do
        if [[ $f != "_index.md" ]]; then
            f=$(echo $f | sed 's`.md``' | awk '{print tolower($0)}')
            echo "1. [$(make_new_title ${f})](${2}/${f}/)"
        fi
    done
}

function populate_missing_index_files() {
    echo "####### Populating Missing Index Files #########"
    for dir in $(find $DESTINATION_DIR -type d)
    do
        relative_path=$(echo -n $dir | sed "s|${DESTINATION_DIR}||")
        if [[ ! -f $dir/_index.md ]] && \
            [[ -z $(echo $relative_path | grep "img") ]] && \
            [[ -z $(echo $relative_path | grep "scripts") ]]; then
            echo "Creating missing index file at $dir/_index.md"
            new_title=$(make_new_title "$(basename $dir)")
            echo "Title: ${new_title}"
            gen_hugo_yaml "$new_title" > $dir/_index.md
            gen_index_header "$new_title" >> $dir/_index.md
            gen_index_content $dir $relative_path >> $dir/_index.md
        fi
    done
}

validate_args $1 $2 $3 $4
SOURCE_DIR=$(cd $2 && pwd)
DESTINATION_DIR=$(cd $4 && pwd)
rm -rf $DESTINATION_DIR && mkdir -p $DESTINATION_DIR
crawl_directory $SOURCE_DIR
populate_missing_index_files
