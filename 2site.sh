#!/usr/bin/bash

SOURCE=source
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
    # cd ..;
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
                composite -gravity south ../../$WM "$f" ../"$PUBLISH"/"$f";
            done;
        cd ..;
    fi
else
    echo File $WM containing watermark must be in the same directory as this script;
fi
