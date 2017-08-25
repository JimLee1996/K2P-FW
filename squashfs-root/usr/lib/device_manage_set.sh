#!/bin/sh
######################################################################
# Copyright (C) 2017. Shanghai Feixun Communication Co.,Ltd.
#
# DISCREPTION   : 终端管理规则配置函数
# AUTHOR        : cong.he <cong.he@phicomm.com.cn>
# CREATED DATE  : 2017-04-28
# MODIFIED DATE :
######################################################################

#set -xv
#set -e

. /lib/functions.sh

rate_limit_set() {
	local ip="$1"
	local src_dst="$2"
	local rate="$3"
	local rate_old="$4"
	if [ $rate_old -gt 0 ]; then
		iptables -t mangle -w -D limit_chain --$src_dst $ip -m hashlimit --hashlimit-name ${src_dst}_$section_name \
			--hashlimit ${rate_old}kb/s --hashlimit-burst ${rate_old}kb/s --hashlimit-mode ${src_dst}ip -j RETURN >/dev/null 2>&1
		iptables -t mangle -w -D limit_chain --$src_dst $ip -j DROP >/dev/null 2>&1
	fi
	if [ $rate -gt 0 ]; then
		iptables -t mangle -w -A limit_chain --$src_dst $ip -m hashlimit --hashlimit-name ${src_dst}_$section_name \
			--hashlimit ${rate}kb/s --hashlimit-burst ${rate}kb/s --hashlimit-mode ${src_dst}ip -j RETURN >/dev/null 2>&1
		iptables -t mangle -w -A limit_chain --$src_dst $ip -j DROP >/dev/null 2>&1
	fi
}

policy_init() {
	local section_iface=$1
	local device ifname
	config_get device "$section_iface" device
	config_get ifname "$section_iface" ifname
	uci set wireless.$device.ac_policy=2
	iwpriv $ifname set AccessPolicy=2
	uci commit wireless
}

entry_set() {
	local section_iface=$1
	local add_del=$2
	local device ifname
	config_get device "$section_iface" device
	config_get ifname "$section_iface" ifname
	if [ "$add_del" = "add" ]; then
		iwpriv $ifname set ACLAddEntry="$MAC"
		uci del_list wireless.${device}.ctrl_list="$MAC"
		uci add_list wireless.${device}.ctrl_list="$MAC"
	elif [ "$add_del" = "del" ]; then
		iwpriv $ifname set ACLDelEntry="$MAC"
		uci del_list wireless.${device}.ctrl_list="$MAC"
	fi
	uci commit wireless
}

block_user_set() {
	local if_type="$1"
	local block_user="$2"
	local block_user_old="$3"
	config_load wireless
	if [ $block_user_old -ne 0 ]; then
		if [ "$if_type" = "0" ]; then
			iptables -t mangle -D PREROUTING -m mac --mac-source $MAC -j DROP
		else
			config_foreach entry_set wifi-iface "del"
		fi
	fi
	if [ $block_user -ne 0 ]; then
		if [ "$if_type" = "0" ]; then
			iptables -t mangle -I PREROUTING -m mac --mac-source $MAC -j DROP
		else
			config_foreach entry_set wifi-iface "add"
		fi
	fi
}

