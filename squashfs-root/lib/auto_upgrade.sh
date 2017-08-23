#!/bin/sh
. /lib/functions.sh
include /lib/upgrade

local string=$(ubus call tr069 check_upgrade)
local retstate=$(uci get onekeyupgrade.config.retState)
local vernum=$(uci get onekeyupgrade.config.VerNUm)
local url=$(uci get onekeyupgrade.config.newurl)
local size=$(uci get onekeyupgrade.config.Size)
if [ "$retstate"x == "1"x ] && [ "$vernum"x == "1"x ]; then
    local imgname=$(echo $url | awk -F "/" '{print $NF}')
    /lib/loadbin.sh $url $size
    if [[ $? == 0 ]]; then
        killall lighttpd; sleep 1; /sbin/sysupgrade /tmp/$imgname
    fi
fi
