#!/bin/sh
append DRIVERS "mt7615e2"

. /lib/wifi/mt7615e.inc

# Hua Shao : This script assumes that:
# 1. 7615 is the only wifi device.
# 2. DBDC=1
# 3. MULTI_PROFILE=1
# 4. DEFAULT_5G=1, which means ra0/rai0/rae0 -> 5G, rax0/ray0/raz0 -> 2G
# If your product is not exactly the same as above, then some minor fixes are necessary.

prepare_mt7615e2() {
	#prepare_ralink_wifi mt7615e
	:
}

scan_mt7615e2() {
	#scan_ralink_wifi mt7615e mt7615e
	:
}

disable_mt7615e2() {
	# unregister hwnat hook.
	iwpriv rax0 set hw_nat_register=0 2>/dev/null || true
	[ x"$2" == x"" ] && {
		disable_mt7615e
		return
	}
	cd /sys/class/net/
	for vif in apcli*; do
		if echo "$vif" | grep -q -e "apcli[xyz]" ; then
			ifconfig $vif down;
		fi
	done
	for vif in ra*; do
		if echo "$vif" | grep -q -e "ra[xyz]" ; then
			ifconfig $vif down;
			ubus call network.interface.lan remove_device "{\"name\":\"$vif\"}"
		fi
	done
}

enable_mt7615e2() {
	[ x"$2" == x"" ] && {
		enable_mt7615e
		return
	}
	[ -f /tmp/mtk/wifi/.mt7615e.1.2g.need_reload ] && {
		cd /sys/class/net/
		for vif in apcli*; do
			ifconfig $vif down;
		done
		for vif in ra*; do
			ifconfig $vif down;
		done
		rmmod mt7615e
		modprobe mt7615e
	}

    uci2dat -d mt7615e2 -f /etc/wireless/mt7615e/mt7615e.1.2G.dat > /tmp/uci2dat.log
	ifconfig ra0 up # ra0 is the root vif
	cd /sys/class/net/
	for vif in ra*; do
		if echo "$vif" | grep -q -e "ra[xyz]" ; then
			ifconfig $vif up;
			ubus call network.interface.lan add_device "{\"name\":\"$vif\"}"
			
			local tmp=$(brctl show | grep $vif)   
			if [ x"$tmp" == x"" ]
			then
				echo "add $vif to br-lan" >> /tmp/wifi.log                 
				brctl addif br-lan $vif                                    
			fi
		fi
	done
	for vif in apcli*; do
		if echo "$vif" | grep -q -e "apcli[xyz]" ; then
			ifconfig $vif up;
		fi
	done

	# register hwnat hook.
	iwpriv rax0 set hw_nat_register=1
}

detect_mt7615e2() {
	#ssid2g=mt7615e-2g-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
	ssid2g=@PHICOMM_`eth_mac r wan | cut -c 16-`
	ssidguest=@PHICOMM_Guest
    [ -e /etc/config/wireless ] && return
         cat <<EOF
config wifi-device      mt7615e2
        option type     mt7615e2
        option vendor   ralink
        option band     2.4G
        option channel  0
        option autoch   2
	option autoch_skip "12;13"
	option region 1
	option country CN
	option wifimode 9
	option bw 2
	option ht_bsscoexist 1
        option g256qam  1

config wifi-iface
        option device   mt7615e2
        option ifname   rax0
        option network  lan
        option mode     ap
        option ssid     $ssid2g
        option encryption none
	option hidden 0
	option disabled 0
	option txbf 0

config wifi-iface
	option device mt7615e2
	option ifname rax1
	option network lan
	option mode ap
	option ssid $ssidguest
	option encryption none
	option disabled 1

EOF
}


