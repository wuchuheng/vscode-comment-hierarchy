#!/bin/bash

tagName=''
if [[ -z ${TAG_NAME} ]]; then
    # the asking message is "Please type the tag name for git: ", and keep the typing in the same line 
    echo "Please type the tag name for git:" 
    read tagName
else
    tagName=${TAG_NAME}
fi

TAG_NAME=${tagName} . scripts/check-tag-name.sh

git tag "${tagName}"

