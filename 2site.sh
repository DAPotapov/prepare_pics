#!/usr/bin/bash 

if [ -z "$*" ]; then
    echo "This script prepares images (changes size and adds watermark) to be published on Wordpress site.";
    echo "Modified files saved in sub-folders.";
    echo "Existing files with same names will be overwritten.";
    echo 
    echo "Syntax: ./2site.sh <folder name> [folder name-2] [...] [*]-for all";
    exit 1;
fi

# Suffixes for processed files' folders
small=_sm
publish=_publish
# This value set for vertical size in wordpress settings
vsize=1024
watermark=watermark.png

check_folder ()
{
    cd "$1" || exit 1;
    # f should be local, otherwise it will contain last precessed node in recursive call and break renaming of processed folder
    local f
    for f in *; do
        if [ -d "$f" ]; then
            if [ "${f: -3}" == "_sm" ] || [ "${f: -8}" == "_publish" ] || [ "${f: -5}" == "_done" ]; then
                echo "'$f' seems like already processed folder - won't be processed"
            else
                check_folder "$f"
                mv "$f" "$f"_done || { echo "Error while renaming processed folder '$f'"; exit 1; }
            fi
        elif [ -f "$f" ]; then
            if [[ $(file --mime-type -b "$f") =~ image* ]]; then
                # Call image processing function with current directory and current file name as arguments
                process_files "${PWD##*/}" "$f"
            else
                echo "'$f' is not an image, won't be processed"
            fi
        else 
            echo "Unable to proceed '$f'. Skipping"
        fi
    done
    cd ..
}

process_files ()
{
    # echo "Folder: $1 , file: $2"
    if [ ! -d "$1$small" ]; then
        mkdir "$1$small" || { echo "Couldn't create folder '$1$small'. Maybe don't have enough permissions."; exit 1; }        
    fi
    height=$(identify -format '%h' "$2")
    if [ "$height" -gt "$vsize" ]; then
        echo "Resizing '$2'";
        convert -resize x$vsize "$2" "$1$small/$2"  || { echo "Couldn't resize file '$2'."; exit 1; }
    else
        echo "File '$2' height ('$height') is lower than '$vsize'. No need to resize";
        cp "$2" "$1$small" || { echo "Error while copying file '$2' to '$1$small'"; exit 1; }
    fi
    if [ ! -d "$1$publish" ]; then
        mkdir "$1$publish" || exit 1;
    fi
    echo "Adding watermark to '$f'";
    composite -gravity south "$watermark" "$2" "$1$publish"/"$2" ||  { echo "Couldn't add watermark."; exit 1; }
}

# Remember full path to watermark file if present
if [ -f "$watermark" ]; then
    watermark=$(pwd)/$watermark 
else
    echo "File '$watermark' containing watermark must be in the same directory as this script";
    exit 1;
fi

for folder in "$@"; do
    if [ "${folder: -1}" == "/" ]; then
        folder="${folder:0: -1}"
    fi
    if [ -d "${folder}" ]; then
        check_folder "${folder}"
    else
        echo "'${folder}' is not a directory, skipping"
    fi
done

