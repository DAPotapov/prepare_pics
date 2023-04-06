#!/usr/bin/bash

# This script prepare images (change size and place watermark)
# to be published on currated Wordpress site.
# It accept folder name to be processed.
# File with watermark should be in same directory as this script

if [ ! -n "$1" ]; then
    echo "Provide a folder name"
    exit 1
fi

SOURCE="$1"
SMALL="$SOURCE"_sm
PUBLISH="$SOURCE"_publish
# This value set for vertical size in wordpress settings
VSIZE=1024
WM=watermark.png

if [ -d "$SOURCE" ]; then
    cd "$SOURCE" || exit 1;
    if [ ! -d "$SMALL" ]; then
        mkdir "$SMALL";
    fi
    mogrify -resize x$VSIZE -path "$SMALL" ./*.jpg;
else
    echo "$SOURCE" directory does not exist;
fi

if [ -f ../"$WM" ]; then
    if [ -d "$SMALL" ]; then
        if [ ! -d "$PUBLISH" ]; then
            mkdir "$PUBLISH"
        fi
        cd "$SMALL" || exit 1;
        for f in ./*.jpg
            do
                echo Adding watermark to "$f";
                composite -gravity south ../../$WM "$f" ../"$PUBLISH"/"$f"; # добавить сюда экзит с эчо на случай ошибки
            done;
        cd ../..;
        mv "$SOURCE" "$SOURCE"_done; # add check for source directory just in case?
        echo "Operation completed";
    fi
else
    echo File $WM containing watermark must be in the same directory as this script;
fi
