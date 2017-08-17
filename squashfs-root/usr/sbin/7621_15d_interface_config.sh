#!/bin/sh

	echo "interface config"
	brctl addbr br-lan
	ifconfig ra0 up
	ifconfig rax0 up
	ifconfig eth0 up
	ifconfig eth1 up
	7621_switch_llllw.sh
	brctl addif br-lan eth0
	brctl addif br-lan rax0
	brctl addif br-lan ra0	
	ifconfig br-lan up
	ifconfig br-lan 192.168.1.1
	ifconfig eth1 192.168.3.1
	
	7621_15d_nat_router_config.sh
	7621_15d_rps_config.sh
