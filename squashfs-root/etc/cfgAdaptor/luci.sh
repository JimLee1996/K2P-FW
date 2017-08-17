############################################################
# Copyright (c) 2016 Shanghai Feixun Communication Co.,Ltd.
# All rights reserved.
#
# FILE NAME  :   luci.sh
# VERSION    :   1.0
# DESCRIPTION:   K2P旧UI升级到新UI时，etc/config/luci文件配置适配
#
# CREATE DATE:   04/06/2017
#
##############################################################

#!/bin/sh
#etc/config/luci文件配置适配

#option name发生变化
uci rename luci.main.userprotocol=agreement

#option取值发生变化
if [[ $(uci get luci.main.lang) == 'zh_cn' ]]; then
		uci set luci.main.lang='zh-cn'
fi
uci set luci.main.mediaurlbase='/luci-static'

#option name和取值都发生变化
if [[ $(uci get luci.main.firststart) == '0' ]]; then
		uci set luci.main.guide='0'
else
		uci set luci.main.guide='1'
fi

#增加新的section
uci set luci.admin=security
uci set luci.admin.username='admin'
uci set luci.admin.password=$(uci get system.weblogin.password)
uci set luci.admin.mtime='0'

#删除旧ui的option
uci delete luci.main.firststart
uci delete luci.languages.zh_cn
uci delete luci.languages.en
uci delete luci.themes.Bootstrap

#uci commit
uci commit luci
