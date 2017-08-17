local s=require("luci.phicomm.error")local o=require("luci.controller.ds")local e=o.filter_key.validator
local l=o.filter_key.args
module("luci.data.safe_set",package.seeall)function index()register_secname_cb("safe_set","config","check_safe_set","apply_safe_set")end
function check_safe_set(i,a,t,i,i,i)o.register_secname_filter(a,t,{enable={[e]="luci.phicomm.validator.check_bool"},dos={[e]="luci.phicomm.validator.check_bool"},icmp_flood={[e]="luci.phicomm.validator.check_bool"},icmp_threshold={[e]="luci.data.safe_set.check_threshold",[l]={5,3600,s.E_ICMP_RANGE}},udp_flood={[e]="luci.phicomm.validator.check_bool"},udp_threshold={[e]="luci.data.safe_set.check_threshold",[l]={5,3600,s.E_UDP_RANGE}},tcp_flood={[e]="luci.phicomm.validator.check_bool"},tcp_threshold={[e]="luci.data.safe_set.check_threshold",[l]={5,3600,s.E_TCP_SYN_RANGE}},ping_disable={[e]="luci.phicomm.validator.check_bool"}})return s.E_NONE
end
function check_threshold(a,o,o,o,l,e,t)local o=require("luci.phicomm.validator")if not o.check_num_range(a,l,e)then
return t
end
return s.E_NONE
end
function apply_safe_set(o,o,o,e,o,o)require("luci.sys")local o=require("luci.model.uci").cursor()if nil~=e.enable and""~=e.enable then
o:set("safeset","config","spi_enable",e.enable)else
o:set("safeset","config","spi_enable","1")end
if e.enable=="1"and nil~=e.dos and""~=e.dos then
o:set("safeset","config","ddos_enable",e.dos)else
o:set("safeset","config","ddos_enable","0")end
if e.enable=="1"and e.dos=="1"and nil~=e.icmp_flood and""~=e.icmp_flood then
o:set("safeset","config","icmp_flood",e.icmp_flood)o:set("safeset","config","icmpflood_rate",e.icmp_threshold)else
o:set("safeset","config","icmp_flood","1")o:set("safeset","config","icmpflood_rate","50")end
if e.enable=="1"and e.dos=="1"and nil~=e.udp_flood and""~=e.udp_flood then
o:set("safeset","config","udp_flood",e.udp_flood)o:set("safeset","config","udpflood_rate",e.udp_threshold)else
o:set("safeset","config","udp_flood","1")o:set("safeset","config","udpflood_rate","500")end
if e.enable=="1"and e.dos=="1"and nil~=e.tcp_flood and""~=e.tcp_flood then
o:set("safeset","config","syn_flood",e.tcp_flood)o:set("safeset","config","synflood_rate",e.tcp_threshold)else
o:set("safeset","config","udp_flood","1")o:set("safeset","config","udpflood_rate","50")end
if e.enable=="1"and e.dos=="1"and nil~=e.ping_disable and""~=e.ping_disable then
o:set("safeset","config","ping_disable",e.ping_disable)else
o:set("safeset","config","ping_disable","0")end
o:save("safeset")o:commit("safeset")luci.sys.exec("/etc/init.d/safeset enable >/dev/null &")luci.sys.exec("/etc/init.d/safeset start >/dev/null &")return s.E_NONE
end
