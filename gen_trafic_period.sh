#!/bin/bash

# Script generate udp traffic 100 times in interval 40-600 second
count=1

while [ $count -le 100 ]
do
    echo "count = $count"
    iperf -c 172.17.2.11 -u -b 150M -t 7 -i 2
    echo "Iperf done. Start sleeping"
    sleep  $((RANDOM % (600 - 40 + 1) + 40))
    echo "Finish sleeping"
    ((count++))
done
