#nvram2uci <nvram-key> <config>.<section>.<option> 
nvram2uci() {
	value=`nvram get linux $1`
	uci set $2=$value
	uci commit
}
