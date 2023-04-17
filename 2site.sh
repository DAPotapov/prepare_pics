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
small_length=${#small}
publish=_publish
publish_length=${#publish}
result=_done
result_length=${#result}
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
            if [ "${f: -$small_length}" == "$small" ] || [ "${f: -$publish_length}" == "$publish" ] || [ "${f: -$result_length}" == "$result" ]; then
                echo "'$f' seems like already processed folder - won't be processed"
            else
                check_folder "$f"
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
    # rename processed folder
    mv "$1" "$1"_done || { echo "Error while renaming processed folder '$1'"; exit 1; }
}

process_files ()
{
    # echo "Folder: $1 , file: $2"
    if [ ! -d "$1$small" ]; then
        mkdir "$1$small" || { echo "Couldn't create folder '$1$small'. Maybe don't have enough permissions."; exit 1; }        
    fi
    fname="${2%.*}"
    fext="${2##*.}"
    if [ "$fext" != jpg ]; then
        newname="$fname".jpg
    else
        newname="$2"
    fi
    height=$(identify -format '%h' "$2")
    if [ "$height" -gt "$vsize" ]; then
        echo "Resizing '$2' to '$newname'";
        convert -resize x$vsize "$2" -strip "$1$small/$newname"  || { echo "Couldn't resize file '$2'."; exit 1; }
    else
        echo "File '$2' height ('$height') not larger than '$vsize'. No need to resize";
        convert "$2" -strip "$1$small/$newname"  || { echo "Couldn't convert file '$2' to jpeg."; exit 1; }
    fi
    if [ ! -d "$1$publish" ]; then
        mkdir "$1$publish" || exit 1;
    fi
    echo "Adding watermark to '$newname'";
    composite -gravity south "$watermark" "$1$small/$newname" "$1$publish"/"$newname" ||  { echo "Couldn't add watermark."; exit 1; }
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
    if [ -d "$folder" ]; then
        check_folder "$folder"
    else
        echo "'$folder' is not a directory, skipping"
    fi
done

