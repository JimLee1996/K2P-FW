#!/bin/sh

	echo "irq/rps config"
	echo 1 > /proc/irq/231/smp_affinity
	echo 2 > /proc/irq/230/smp_affinity
	echo 4 > /proc/irq/225/smp_affinity
	echo 8 > /proc/irq/226/smp_affinity
	
	echo 3 > /sys/class/net/ra0/queues/rx-0/rps_cpus
	echo 3 > /sys/class/net/ra1/queues/rx-0/rps_cpus
	echo 5 > /sys/class/net/eth0/queues/rx-0/rps_cpus
	echo 5 > /sys/class/net/eth1/queues/rx-0/rps_cpus
