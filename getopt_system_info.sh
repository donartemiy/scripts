#!/bin/bash

# Sprint 4: Bash scripts.
# Script shows systems info, users info.

# You can find examples to use possabilities of bash: 
#   functions, getopt, loops (while, for), conditionals(if, case), awk, grep

# Data gets from:
#   Utilities: ifconfig; sudo -v; netstat; lsblk -fs -d; free -h; uptime; df -h; who; getent
#   files:
#     /proc/loadavg
#     /proc/diskstats
#     /proc/cpuinfo
#     /proc/loadavg
#     /etc/passwd

# Exit immediately if a command exits with a non-zero status.
set -e

function show_help() {
    echo -e "Usage:\n script.sh [OPTIONS]\n"
    echo " --host                     show info about system"
    echo " --user                     show info about users"
    echo " --help                     help"
}


function show_interface_data() {
    # Reading ifconfig line by line and find info you needed
    echo "$(ifconfig)" | while read -r LINE; do
        # Use different delimetr
        echo "$LINE" | awk -F'[:<,]' '/: flags=/ {print " - Interface:", $1, "Status:", $3}'
        echo "$LINE" | awk '/^inet/ {print "   - IP:", $2}'
        echo "$LINE" | awk '/RX packets/ {print "   - RX packets:", $3}'
        echo "$LINE" | awk '/RX errors/ {print "   - RX errors:", $3}'
        echo "$LINE" | awk '/TX packets/ {print "   - TX packets:", $3}'
        echo "$LINE" | awk '/TX errors/ {print "   - TX errors:", $3}'
    done
}


function show_open_sockets() {
    TESTSUDO=`sudo -v`
    # root check
    if [[ -z $TESTSUDO ]]; then
        sudo netstat -nltp | awk '/LISTEN/ {print $4}' | awk -F ':' '{print " - ", $NF}' | sort | uniq
    else
        netstat -nltp | awk '/LISTEN/ {print $4}' | awk -F ':' '{print " - ", $NF}' | sort | uniq
    fi
}


function show_disk_stat() {
    # define name of disks
    DISKS=`lsblk -fs -d -o NAME,MOUNTPOINT | awk '{ if ($2 != "" && $2 !="MOUNTPOINT") print $1 }'`
    for DISKNAME in $DISKS; do
        echo " - $DISKNAME:"
        df -h | grep "$DISKNAME" | awk '{print "   - Size:", $2}'
        df -h | grep "$DISKNAME" | awk '{print "   - Free:", 100-$5 "%"}'
        grep "$DISKNAME" /proc/diskstats | awk '{print "   - sectors discarded:", $17}'
    done
}


# If script doesn't get any OPTIONS
if [ $# == 0 ]; then
   show_help
fi

# Parse OPTIONS
OPTIONS=$(getopt -o "" -l "host,user,help" -- "$@")

while true; do
    # Conditional to different OPTIONS
    case "$1" in
        "--host")
            echo "Host info:"
            # split pipe segment \ + |
            AMOUNTCORE=`cat /proc/cpuinfo \
                | awk '/cpu cores/ { sum += $4} END { print sum}'` && echo "1. Quantity of cores: $AMOUNTCORE"
            MEMINF=`free -h | grep 'Mem' \
                | awk '{ print "total", $2, "/", "avail", $7}'` && echo "2. Memory info: $MEMINF"
            echo "3. Slisten ports:"
            show_disk_stat
            LOADAVG=`awk '{ print "\n - last 1m", $1";\n", "- last 5m", $2";\n", "- last 15m", $3 }' /proc/loadavg` && echo "4. Load average: $LOADAVG"
            TIME=`uptime | awk '{ print $1 }'` && echo "5. DATE (UTC): $TIME" 
            UPTIME=`uptime | awk '{ print $3 }'` && echo "6. Uptime: $UPTIME" 
            echo "7. Information about interfaces:"
            show_interface_data
            echo "8. Slisten ports:"
            show_open_sockets
            break ;;
        "--user")
            echo "1. User's list in system:"
            awk -F ':' '{printf "   " $1 }' /etc/passwd
            echo
            echo "2. Root users list in system:"
            awk -F: '$3 == 0 { print "   " $1 }' /etc/passwd
            echo "3. User's list who is logged on:"
            echo "   $(getent group sudo)"
            break
            ;;
        "--help")
            show_help
            break
            ;;
        *)
            echo "wrong OPTIONS / arguments"
            break;;
    esac
done
