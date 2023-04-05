#!/usr/bin/bash

SOURCE=source
SMALL=sm
PUBLISH=publish
WM=watermark.png

if [ ! -d $SMALL ]; then
    mkdir sm;
fi

if [ -d $SOURCE ]; then
    cd $SOURCE;
    mogrify -resize x1024 -path ../$SMALL *.jpg;
    cd ..;
else
    echo $SOURCE directory does not exist;
fi

if [ -f $WM ]; then
    if [ -d $SMALL ]; then
        if [ ! -d $PUBLISH ]; then
            mkdir $PUBLISH
        fi
        cd $SMALL
        for f in *.jpg
            do
                echo Adding watermark to $f;
                composite -gravity south ../$WM "$f" ../$PUBLISH/"$f";
            done;
        cd ..;
    fi
else
    echo File $WM containing watermark must be in the same directory as this script;
fi
