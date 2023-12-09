#!/bin/bash

# Load the common functions:check_tag_name_exited_in_change_log 
. scripts/common.sh # {check_tag_name_exited_in_change_log}

tagName=''
if [[ -z ${TAG_NAME} ]]; then
    # the asking message is "Please type the tag name for git: ", and keep the typing in the same line 
    echo "Please type the tag name for git:" 
    read tagName
else
    tagName=${TAG_NAME}
fi



##
# Check the tag name is valid 
# @param --tag-name the tag name
# @use check_tag_name_valid --tag-name <tag name>
##
function check_tag_name_valid() {
    local tagName=''
    for i in $@; do
        case $i in
            --tag-name) 
                tagName=$2; 
                shift 2
            ;;
            *) 
                [[ -n $1 ]] && shift
            ;;
        esac
    done
    # Check if tag name fits the pattern
    if ! [[ $tagName =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
    then
        error --msg "Tag name $tagName does not match the pattern 'vX.Y.Z'"
    fi
}

check_tag_name_valid --tag-name "${tagName}"

check_tag_name_exited_in_change_log --tag-name "${tagName}"

# print the OK message in green color
echo -e "\033[32mTag name: ${tagName} OK\033[0m"

