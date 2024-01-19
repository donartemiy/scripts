#!/bin/bash
# Smart grep. Script finds mess string which get from file str_to_grep.txt
# (!) file str_to_grep.txt must be in another dir

while read -r LINE
do
    echo "$LINE"
    grep -rq ${LINE} *
    if [ $? != 0 ]; then
        echo "NOT MATCH"
    fi
done < /../str_to_grep.txt
