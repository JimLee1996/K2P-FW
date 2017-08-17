#!/bin/sh

	echo "nat modules load"
	modprobe /lib/modules/3.10.20/ip_tables.ko
	modprobe /lib/modules/3.10.20/ipt_MASQUERADE.ko
	modprobe /lib/modules/3.10.20/ipt_REJECT.ko
	modprobe /lib/modules/3.10.20/iptable_nat.ko
	modprobe /lib/modules/3.10.20/nf_conntrack_ipv4.ko
	modprobe /lib/modules/3.10.20/iptable_nat.ko
	iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -o eth1 -j MASQUERADE
	echo 1 > /proc/sys/net/ipv4/ip_forward