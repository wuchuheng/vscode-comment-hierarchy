#!/bin/bash

tagName=''
if [[ -z ${TAG_NAME} ]]; then
    # the asking message is "Please type the tag name for git: ", and keep the typing in the same line 
    echo "Please type the tag name for git:" 
    read tagName
else
    tagName=${TAG_NAME}
fi

changeLogFile="CHANGELOG.md"

##
# print the error msssage 
# @param --msg the error message
##
function error() {
    local msg=''
    for i in $@; do
        case $i in
            --msg) 
                msg=$2; 
                shift 2
            ;;
            *) 
                [[ -n $1 ]] && shift
            ;;
        esac
    done
    # print the error massage in red color and with the exit code 1
    echo -e "\033[31mError: $msg\033[0m";
    exit 1
}

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

##
# check the tag name existed in the change log
# @param --tag-name the tag name
##
function check_tag_name_exited_in_change_log() {
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
    tagName=${tagName:1}



    local REPO_ROOT=$(git rev-parse --show-toplevel)
    cd "$REPO_ROOT"

    local lineNumWithTagNameTxt=$(git show "$tagName:${changeLogFile}" | grep -En "^##\s+\[\d+\.\d+\.\d+\]" )
    local preTagName=''
    # to split the lineNumWithTagNameTxt with \n
    IFS=$'\n' read -d '' -ra lineNumWithTagNameList <<<"$lineNumWithTagNameTxt" || true

    for line in "${lineNumWithTagNameList[@]}"; do
        # get the line number and tag name
        local lineNumberWithTag=$(
            echo $line \
            | sed -E "s/^([0-9]+):##[[:space:]]+\[([0-9]+\.[0-9]+\.[0-9]+)\].*$/\1:\2/g";
        )
        local lineNO=${lineNumberWithTag%:*}
        local lineTagName=${lineNumberWithTag#*:}

        if [[ ${lineTagName} == ${tagName} ]]; then
            return 0
        fi
    done
    error --msg "Tag name $tagName does not exist in the change log"
}

check_tag_name_valid --tag-name "${tagName}"

check_tag_name_exited_in_change_log --tag-name "${tagName}"

