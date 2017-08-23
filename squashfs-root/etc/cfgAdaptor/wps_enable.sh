############################################################
# Copyright (c) 2016 Shanghai Feixun Communication Co.,Ltd.
# All rights reserved.
#
# FILE NAME  :   luci.sh
# VERSION    :   1.0
# DESCRIPTION:   K2P旧UI升级到新UI时，etc/config/wps_config文件配置适配
#
# CREATE DATE:   08/06/2017
#
##############################################################

#!/bin/sh
#etc/config/wps_config 文件配置适配

#option取值升级时初始化为wps开启状态
uci set wps_config.wps_para.wps_enable='1'

#uci commit
uci commit wps_config
