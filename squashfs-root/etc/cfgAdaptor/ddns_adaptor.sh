############################################################
# Copyright (c) 2016 Shanghai Feixun Communication Co.,Ltd.
# All rights reserved.
#
# FILE NAME  :
# VERSION    :
# DESCRIPTION:   K2P旧UI升级到新UI时，etc/config/ddns文件配置适配
#
# CREATE DATE:   17/06/2017
#
##############################################################

#!/bin/sh
#etc/config/ddns 文件配置适配

if [[ $(uci get ddns.myddns.service_name) == '3322.org' ]]; then
	uci set ddns.myddns.service_name='pubyun.com'
fi

uci commit ddns
