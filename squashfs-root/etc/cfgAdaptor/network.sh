#!/bin/sh
#etc/config/network文件配置适配

uci rename network.wan.pppoednsmode=pppoe_dns_mode
uci rename network.wan.dhcpdnsmode=dhcp_dns_mode

if [[ $(uci get network.wan.proto) == 'pppoe' ]]; then
	uci set network.wan.pppoedns1=$(uci get network.wan.dns1)
	uci set network.wan.pppoedns2=$(uci get network.wan.dns2)
fi

if [[ "$(uci get network.static.mtu)" == "" ]]; then
	uci set network.wan.ignore_mtu_change_pppoe="1"
else
	uci set network.wan.ignore_mtu_change_pppoe="0"
fi

if [[ "$(uci get network.wan.mtu)" == "" ]]; then
	uci set network.wan.mtu='1500'
fi

if [[ "$(uci get network.wan.peerdns)" == "" ]]; then
	uci set network.wan.peerdns='1'
fi

if [[ "$(uci get network.wan.macoperate)" == "" ]]; then
	uci set network.wan.macoperate='1'
fi

uci delete network.wan.detectwanproto
uci delete network.wan.enable_advance
uci commit network