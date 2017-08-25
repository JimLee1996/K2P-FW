#!/bin/sh
#etc/config/appportfwd文件配置适配

i=0
while [[ true ]]; do
	#statements
	if [[ `uci get appportfwd.@setting[$i])` == "setting" ]]; then
		uci set appportfwd.@setting[$i].id=$i
		let i=i+1
	else
		break
	fi
done

#uci commit
uci commit appportfwd