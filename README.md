### K2P Firmware官改版

Already removed harmful functions:

- adpush
- data_collect
- kmod-price_compare
- tr069

Already removed useless functions:

- telnetd_startup
- speedtest
- usb
- block-mount
- ddns
- kmod-nls-cp437
  kmod-nls-cp850
  kmod-nls-iso8859-1
  kmod-nls-iso8859-15

Already enabled functions:

- telnet
- opkg

Not yet

```
/etc/
	config/update_up
	init.d/update_up
	lc

/usr/
	bin/router-helper
	sbin/update_up
luci-app-h5 - git-adab218-1
oui_update - 1
reg - 1
router-helper - 1
schemeupgrade - 1.0-1
tnat - 1
update_usrproto - 1
```

#### Usage

```shell
./tool.sh -c new.bin # create new firmware from kernel.bin and squashfs-root
./tool.sh -e old.bin # extract firmware to kernel.bin and squashfs-root
```

#### Platform

Ubuntu 16.04 amd64

#### Depends

##### Binwalk

```shell
apt install binwalk
```

##### firmware-tool

https://github.com/openwrt-dev/firmware-tools

You should manually compile and install it to use opkg

#### Modify

```shell
cd squashfs-root
opkg update
opkg list-installed
opkg remove PackageName
opkg install PackageName
... ...
```

