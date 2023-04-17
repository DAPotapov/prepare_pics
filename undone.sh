#!/usr/bin/bash 

# Suffixes for processed files' folders 
small=_sm
small_length=${#small}
publish=_publish
publish_length=${#publish}
result=_done
result_length=${#result}

restore ()
{
    local len=${#1}
    if [ "${1: -$result_length}" == "$result" ]; then
        echo "Folder name of '$1' without suffix is '${1:0 : $len-result_length}'"    
        cd "$1" || exit 1;
        local f
        for f in *; do
            if [ -d "$f" ]; then
                if [ "${f: -$small_length}" == "$small" ] || [ "${f: -$publish_length}" == "$publish" ]; then
                    echo "'$f' will be deleted"
                    rm -r "$f" || { echo "Failed to delete";}
                elif [ "${f: -$result_length}" == "$result" ]; then
                    restore "$f"
                else
                    echo "'$f' seems unprocessed. Ignoring"                
                fi
            elif [ -f "$f" ]; then
                echo "'$f' is file. Ignoring"
            else 
                echo "Unable to proceed '$f'. Skipping"
            fi
        done
        cd ..
        echo "Renaming '$1' (length is '$len') to '${1:0 : $len-result_length}'"
        mv "$1" "${1:0 : $len-result_length}" || { echo "Failed to rename"; }
    fi
}

if [ -z "$*" ]; then
    echo "This script returns testing folder structure to previous state.";
    echo 
    echo "Syntax: ./undone.sh <folder name> [folder name-2] [...] [*]-for all";
    exit 1;
fi

for folder in "$@"; do
    if [ "${folder: -1}" == "/" ]; then
        folder="${folder:0: -1}"
    fi
    if [ -d "$folder" ]; then
        restore "$folder"
    else
        echo "'$folder' is not a directory, skipping"
    fi
done