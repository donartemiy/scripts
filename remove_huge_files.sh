#!/bin/bash
# delete files in curent directory which more than 10000K

for FILE_NAME in $(ls); do
    # echo $FILE_NAME
        if [ -f $FILE_NAME ] && [ $(du -k "$FILE_NAME" | awk {'print $1'}) -ge 10000 ]; then
                    echo "$(sudo du -k "$FILE_NAME")"
                    sudo rm $FILE_NAME
                    echo "file was deleted: $FILE_NAME"
        fi
done
