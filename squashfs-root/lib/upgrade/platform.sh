#
# Copyright (C) 2010 OpenWrt.org
#

. /lib/ramips.sh
. /lib/functions.sh

PART_NAME=firmware
RAMFS_COPY_DATA=/lib/ramips.sh

UBOOT_FILE=/tmp/uboot.bin
KERNELFS_FILE=/tmp/fs.bin
FWINFO_FILE=/tmp/fw_info.json
OWINFO_FILE=/tmp/ow_info.json

sync_config_paritition(){
	local FW_VER
	local HW_ID

	local DG_VER
	local RETAIL_REGION
	local PRODUCT_ID

	json_load "$(cat $FWINFO_FILE)"
	json_get_var FW_VER FW_VER

	json_load "$(cat $OWINFO_FILE)"
	json_get_var DG_VER DG_VER
	json_get_var HW_ID HW_ID
	json_get_var PRODUCT_ID PRODUCT_ID
	json_get_values retail_regions RETAIL_REGION

	json_init
	json_add_object fw_info
	json_add_string FW_VER $FW_VER
	json_close_object

	json_add_object ow_info
	json_add_string DG_VER $DG_VER
	json_add_string HW_ID $HW_ID
	json_add_string PRODUCT_ID $PRODUCT_ID
	json_add_array RETAIL_REGION
	for region in $retail_regions; do
		json_add_string RETAIL_REGION $region
	done
	json_close_array
	json_close_object

#	json_dump
	config_util -w "$(json_dump)"
}

sop_dec_image() {
	sync
	echo 3 > /proc/sys/vm/drop_caches
	img-dec $1 $FWINFO_FILE $OWINFO_FILE $UBOOT_FILE $KERNELFS_FILE
	return $?
}

platform_check_image() {
	rm -f /tmp/.upgrade_req_ver
	rm -f /tmp/.upgrade_dg_ver

	if ! sop_dec_image $1; then
		echo "Invalid sop image"
		rm $KERNELFS_FILE
		return 1
	fi

	# 版本检查
	if ! jshn -r "$(cat $FWINFO_FILE)"; then
		echo "Invalid fw_info"
		rm $KERNELFS_FILE
		return 1
	fi

	# 对比版本
	. /usr/share/libubox/jshn.sh
	json_load "$(cat $FWINFO_FILE)"
	json_get_var _fw_ver FW_VER
	json_get_var _req_ver REQ_VER
	json_get_var _hw_id HW_ID
	json_get_keys _pids PRODUCT_ID

	_our_hw_id=`uci get dev_info.dev_info.hw_id`
	_our_pid=`uci get dev_info.dev_info.product_id`

	# 比较硬件是否一致
	if [ $_hw_id != $_our_hw_id ]; then
		rm $KERNELFS_FILE
		return 1
	fi

	# 比较产品ID是否一致
	local flag=0
	json_select PRODUCT_ID
	for _idx in $_pids; do
		json_get_var _pid $_idx
		if [ $_pid == $_our_pid ]; then
			flag=1
			break
		fi
	done
	if [ $flag -ne 1 ]; then
		rm $KERNELFS_FILE
		return 1
	fi

	_our_fw_ver=`uci get system.system.fw_ver`

	# 特殊版本，用于测试，跳过版本校验
	if [[ $(verrevcmp $_fw_ver 0.0.0.1) -ne 0 ]]; then

		if [[ $(verrevcmp $_our_fw_ver $_req_ver) -lt 0 ]]; then
			echo "Unsatisfied fw version: $_our_fw_ver < $_req_ver (req ver)"
			echo "$_req_ver" > /tmp/.upgrade_req_ver
			rm $KERNELFS_FILE
			return 2
		fi

		_dg_ver=`uci get dev_info.dev_info.dg_ver`
		if [[ $(verrevcmp $_fw_ver $_dg_ver) -le 0 ]]; then
			echo "Unsatisfied fw version: $_fw_ver <= $_dg_ver (dg ver)"
			echo "$_dg_ver" > /tmp/.upgrade_dg_ver
			rm $KERNELFS_FILE
			return 3
		fi
		sync_config_paritition
	fi

	return 0
}

platform_config_prepare() {
	# overwrite dev_info
	jshn -r "$(cat $OWINFO_FILE)" && { # 正确解析才进行覆盖
		. /usr/share/libubox/jshn.sh
		json_load "$(cat $OWINFO_FILE)"
		json_get_var _dg_ver DG_VER
		json_get_var _hw_id HW_ID
		json_get_var _pid PRODUCT_ID

		uci set dev_info.dev_info.dg_ver="$_dg_ver"
		uci set dev_info.dev_info.hw_id="$_hw_id"
		uci set dev_info.dev_info.product_id="$_pid"

		uci delete dev_info.dev_info.retail_region
		json_get_keys _rr_num RETAIL_REGION
		json_select RETAIL_REGION
		for _idx in $_rr_num; do
			json_get_var _rr $_idx
			uci add_list dev_info.dev_info.retail_region="$_rr"
		done
		uci commit dev_info
	}

	# update fw_ver
	. /usr/share/libubox/jshn.sh
	json_load "$(cat $FWINFO_FILE)"
	json_get_var _fw_ver FW_VER
	uci set system.system.fw_ver="$_fw_ver"
	uci commit system
}

sop_do_upgrade() {
	sync

	# bootloader
	_new=`md5sum $UBOOT_FILE | awk '{print $1}'`
	_old=`md5sum /dev/mtdblock$(find_mtd_index Bootloader) | awk '{print $1}'`
	if [[ ! "$_new" = "$_old" ]]; then
		echo "Upgrade bootloader ..."
		get_image "$UBOOT_FILE" | mtd write - "Bootloader"
	fi

	# kernel + fs
	if [ "$SAVE_CONFIG" -eq 1 ]; then
		get_image "$KERNELFS_FILE" | mtd $MTD_CONFIG_ARGS -j "$CONF_TAR" write - "${PART_NAME:-image}"
	else
		get_image "$KERNELFS_FILE" | mtd write - "${PART_NAME:-image}"
	fi

	# NOTE 升级之后尽量不要执行其他操作，因为很多命令此时已经不存在
}

platform_do_upgrade() {
	local board=$(ramips_board_name)

	case "$board" in
	*)
		#default_do_upgrade "$ARGV"
		sop_do_upgrade
		;;
	esac
}

disable_watchdog() {
	killall watchdog
	( ps | grep -v 'grep' | grep '/dev/watchdog' ) && {
		echo 'Could not disable watchdog'
		return 1
	}
}

append sysupgrade_pre_upgrade disable_watchdog

