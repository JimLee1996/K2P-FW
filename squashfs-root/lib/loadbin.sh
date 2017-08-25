#!/bin/sh
. /lib/functions.sh
include /lib/upgrade

if [ $# != 2 ]; then
        exit 1
fi

LOCK_NAME="/tmp/loadbin.lock"

if [[ -e $LOCK_NAME ]];then
        echo "exiting"
        exit 1
fi

echo $LOCK_NAME > "$LOCK_NAME"

local url=$1
local size=$2
local free=$(free | grep Mem | awk '{ print $4 }')
if [ $((${free}*1024)) -gt $((size)) ]; then
        local binname=$(echo $url | awk -F "/" '{print $NF}')
        wget -T 30 $url -P /tmp/
        local size_new=$(ls -l /tmp/$binname | awk '{ print $5 }')
        if [[ $size = $size_new ]];then
                rm -rf $LOCK_NAME
                exit 0
        else
                rm -rf $LOCK_NAME
                exit 1
        fi
else
        rm -rf $LOCK_NAME
        exit 1
fi
