#!/bin/bash
# Author: Artemiy
# Script collects mtr result. Required options src and dst IP.
# example to use: ./mtr_jitter.sh 10.76.5.235 8.8.8.8

COMMAND=`mtr -r -c 300 --order SRBWJMXI --address $1 SRBWJMXI $2`

for i in {1..6}
do
    echo "${COMMAND}" >> mtr_results.txt
done
