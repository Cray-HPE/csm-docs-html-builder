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

# Generates resulting YAML config file, by replacing ${BRANCH} and other tokens
# in input file with values from ${BRANCHES} array and merging result into single file.
# Recognized tokens:
# ${BRANCH} - branch name from ${BRANCHES} array define din the config file
# ${SUFFIX} - branch name with dots stripped (e.g. 1.2 turns to 12)
# ${LAST_SUFFIX} - ${SUFFIX} generated for last branch
# ${WEIGHT} - a number evaluated as <branch_index> * 10 (for Hugo config file weights)
# ${PRODUCT_NAME} - product name (csm, sat, etc)
#
function generate_yaml() {
    INFILE="${1}"
    OUTFILE="${2}"
    touch "${OUTFILE}"
    LAST_SUFFIX=${BRANCHES[${#BRANCHES[@]}-1]//./}
    for INDEX in "${!BRANCHES[@]}"; do
        BRANCH="${BRANCHES[$INDEX]}"
        SUFFIX="${BRANCH//./}"
        WEIGHT="$(($INDEX * 10))"
        cat "${INFILE}" \
            | sed -e "s/^#.*//" \
            | sed -e "s/\${LAST_SUFFIX}/${LAST_SUFFIX}/" \
            | sed -e "s/\${SUFFIX}/${SUFFIX}/" \
            | sed -e "s/\${BRANCH}/${BRANCH}/" \
            | sed -e "s/\${WEIGHT}/${WEIGHT}/" \
            | sed -e "s/\${PRODUCT_NAME}/${PRODUCT_NAME}/" \
            | yq ea -i '. as $item ireduce ({}; . * $item )' "${OUTFILE}" -
    done
    echo "Generated YAML file ${OUTFILE}:"
    cat "${OUTFILE}"
}