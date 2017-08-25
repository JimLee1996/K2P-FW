#!/bin/sh
######################################################################
# Copyright (C) 2016. Shanghai Feixun Communication Co.,Ltd.
#
# DISCREPTION   : 机型相关的方法
# AUTHOR        : xiongyi.ouyang <xiongyi.ouyang@phicomm.com.cn>
# CREATED DATE  : 2016-08-10
# MODIFIED DATE : 
######################################################################

# 判断设备是否校准过
wireless_calibrated() {
	return 1
}

. /lib/product_ow.sh 2>/dev/null
