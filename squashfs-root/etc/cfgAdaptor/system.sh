############################################################
# Copyright (c) 2016 Shanghai Feixun Communication Co.,Ltd.
# All rights reserved.
#
# FILE NAME  :   system.sh
# VERSION    :   1.0
# DESCRIPTION:   K2P旧UI升级到新UI时，etc/config/system文件配置适配
#
# CREATE DATE:   31/0７/2017
#
##############################################################

#!/bin/sh
#etc/config/system文件配置适配
uci set system.system.domain='p.to'

#uci commit
uci commit system