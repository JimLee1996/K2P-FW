#!/bin/sh
######################################################################
# Copyright (C) 2016. Shanghai Feixun Communication Co.,Ltd.
#
# DISCREPTION   : SOP平台相关的方法
# AUTHOR        : xiongyi.ouyang <xiongyi.ouyang@phicomm.com.cn>
# CREATED DATE  : 2016-08-10
# MODIFIED DATE :
######################################################################

. /lib/product.sh

build_type() {
    cat /rom/etc/banner | grep BUILD_TYPE | cut -d '=' -f 2
}

__log_dump() {
    set -e
    rm -rf /tmp/log_dump*

    __abort() {
        logger -t log_dump -p err "Aborted!"
        rm -rf /tmp/log_dump*
        trap - EXIT
        exit 1
    }

    export __dump_dir=$1

    trap __abort EXIT INT TERM

    mkdir -p /tmp/$__dump_dir

    #######################
    # 只支持debug类型固件
    #######################

    if [[ `build_type` = "debug" ]]; then
        logread >/tmp/$__dump_dir/syslog
        cp -r /etc/config /tmp/$__dump_dir/config
        cp /rom/etc/banner /tmp/$__dump_dir/rom_banner
        top -b -n 1 > /tmp/$__dump_dir/top_info
        ifconfig > /tmp/$__dump_dir/ifconfig
        route -n > /tmp/$__dump_dir/route
        netstat -na > /tmp/$__dump_dir/netstat

        mkdir -p /tmp/$__dump_dir/proc
        cat /proc/meminfo > /tmp/$__dump_dir/proc/meminfo
        cat /proc/uptime > /tmp/$__dump_dir/proc/uptime
        cat /proc/loadavg > /tmp/$__dump_dir/proc/loadavg
        cat /proc/slabinfo > /tmp/$__dump_dir/proc/slabinfo

        mkdir -p /tmp/$__dump_dir/iptables
        iptables -t nat -S > /tmp/$__dump_dir/iptables/nat
        iptables -t filter -S > /tmp/$__dump_dir/iptables/filter
    fi

    #######################
    # 任意固件模式
    #######################

    if wireless_calibrated; then
        echo "wireless_calibrated=true" >> /tmp/$__dump_dir/misc
    else
        echo "wireless_calibrated=false" >> /tmp/$__dump_dir/misc
    fi

    cd /tmp
    tar czf "$__dump_dir".tgz $__dump_dir

    rm -rf /tmp/$__dump_dir

    trap - EXIT
    logger -t log_dump -p err "Done!"
}

log_dump() {
    local __dump_dir=log_dump_$(phic_fac -g mac | cut -d '=' -f 2 | sed -e 's/:/-/g')_$(date +"%Y.%m.%d_%T" | sed -e 's/:/-/g')
    if $(__log_dump $__dump_dir) ;then
        echo "$__dump_dir".tgz
        return 0
    else
        return 1
    fi
}
