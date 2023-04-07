#!/usr/bin/bash

if [ -z "$1" ]; then
    echo "This script prepares images (changes size and adds watermark) to be published on Wordpress site.";
    echo "Modified files saved in sub-folders.";
    echo "Existing files with same names will be overwritten.";
    echo 
    echo "Syntax: ./2site.sh <folder name>";
    exit 1;
fi

SOURCE="$1"
SMALL="$SOURCE"_sm
PUBLISH="$SOURCE"_publish
# This value set for vertical size in wordpress settings
VSIZE=1024
# WM=nofile.png # for testing purposes
WM=watermark.png

if [ -d "$SOURCE" ]; then
    cd "$SOURCE" || exit 1;
    if [ ! -d "$SMALL" ]; then
        mkdir "$SMALL" || { echo "Couldn't create folder '$SMALL'. Maybe don't have enough permissions."; exit 1; }
    fi
    for f in ./*.jpg
        do 
            height=$(identify -format '%h' "$f")
            if [ "$height" -gt "$VSIZE" ] 
            then
                echo "Resizing '$f'";
                mogrify -resize x$VSIZE -path "$SMALL" "$f" || { echo "Couldn't resize file '$f'."; exit 1; }
            else
                echo "File '$f' height ('$height') is lower than '$VSIZE'. Left unchanged.";
                cp "$f" "$SMALL";
            fi
        done
else
    echo "'$SOURCE' directory does not exist";
    exit 1;
fi

if [ -f ../"$WM" ]; then
        if [ ! -d "$PUBLISH" ]; then
            mkdir "$PUBLISH" || exit 1;
        fi
        cd "$SMALL" || { echo "'$SMALL' folder dissapeared!!"; exit 1;}
        for f in ./*.jpg 
            do
                if [ -f "$f" ]; then                
                    echo "Adding watermark to '$f'";
                    composite -gravity south ../../$WM "$f" ../"$PUBLISH"/"$f" ||  { echo "Couldn't add watermark."; exit 1; }
                else
                    echo "File '$f' not found";
                    exit 1;
                fi
            done
        cd ../..;
        if mv "$SOURCE" "$SOURCE"_done
            then echo "Operation completed";
        else echo "'$SOURCE' folder rename failed";
            exit 1;
        fi        
else
    echo "File '$WM' containing watermark must be in the same directory as this script";
fi
