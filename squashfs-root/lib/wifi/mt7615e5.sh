#!/bin/sh
append DRIVERS "mt7615e5"

. /lib/wifi/mt7615e.inc

# Hua Shao : This script assumes that:
# 1. 7615 is the only wifi device.
# 2. DBDC=1
# 3. MULTI_PROFILE=1
# 4. DEFAULT_5G=1, which means ra0/rai0/rae0 -> 5G, rax0/ray0/raz0 -> 2G
# If your product is not exactly the same as above, then some minor fixes are necessary.

prepare_mt7615e5() {
	#prepare_ralink_wifi mt7615e
	:
}

scan_mt7615e5() {
	#scan_ralink_wifi mt7615e mt7615e
	:
}

disable_mt7615e5() {
	# unregister hwnat hook.
	iwpriv ra0 set hw_nat_register=0 2>/dev/null || true

	[ x"$2" == x"" ] && {
		# let mt7615e2 do the work
		return
	}
	cd /sys/class/net/
	for vif in apcli*; do
		if echo "$vif" | grep -q -e "apcli[0-9ie]" ; then
			ifconfig $vif down;
		fi
	done
	for vif in ra*; do
		if echo "$vif" | grep -q -e "ra[0-9ie]" ; then
			ifconfig $vif down;
			ubus call network.interface.lan remove_device "{\"name\":\"$vif\"}"
		fi
	done
}

enable_mt7615e5() {

	[ x"$2" == x"" ] && {
		# let mt7615e2 do the work
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

    uci2dat -d mt7615e5 -f /etc/wireless/mt7615e/mt7615e.1.5G.dat > /tmp/uci2dat.log
	ifconfig ra0 up # ra0 is the root vif

	cd /sys/class/net/
	for vif in ra*; do
		if echo "$vif" | grep -q -e "ra[0-9ie]" ; then
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
		if echo "$vif" | grep -q -e "apcli[0-9ie]" ; then
			ifconfig $vif up;
		fi
	done

	# register hwnat hook.
	iwpriv ra0 set hw_nat_register=1 2>/dev/null || true
}

detect_mt7615e5() {
	#ssid5g=mt7615e-5g-`ifconfig eth0 | grep HWaddr | cut -c 51- | sed 's/://g'`
	ssid5g=@PHICOMM_`eth_mac r wan | cut -c 16-`_5G
    [ -e /etc/config/wireless ] && return
         cat <<EOF
config wifi-device      mt7615e5
        option type     mt7615e5
        option vendor   ralink
        option band     5G
        option channel  0
        option autoch   2
	option autoch_skip "52;56;60;64"
	option aregion 0
	option country CN
	option wifimode 14
	option bw 1
	option ht_bsscoexist 1
        option g256qam  1

config wifi-iface
        option device   mt7615e5
        option ifname   ra0
        option network  lan
        option mode     ap
        option ssid     $ssid5g
        option encryption none
	option hidden 0
	option disabled 0
	option ApCliEnable 0
	option txbf 0
EOF
}


