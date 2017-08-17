#!/bin/sh

# 在 ramfs 处理的任务


ramfs_do(){
	echo writing uboot >> $UPGRADE_LOG
	mtd write "$UBOOT" "$BOOTLOADER"
	echo writing firmware >> $UPGRADE_LOG
	mtd -j "$BACKUP_OVERLAY" write "$KFS" "$FIRMWARE"
	echo upgrade finished >> $UPGRADE_LOG
	sleep 3
	reboot -f
	#echo b > /proc/sysrq-trigger
}
