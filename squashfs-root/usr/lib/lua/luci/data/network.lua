local e=require("luci.phicomm.error")local t=require("luci.phicomm.validator")local r=require("luci.controller.ds")local n=r.filter_key.validator
local o=r.filter_key.args
local a=require("luci.controller.admin.device")local c=require("luci.phicomm.lib.bit").bit
local c=28
module("luci.data.network",package.seeall)function index()register_secname_cb("network","wan","check_wan","apply_network_config_wan")register_secname_cb("network","static","check_static","apply_network_config_static")register_secname_cb("network","dhcp","check_dhcp","apply_network_config_dhcp")register_secname_cb("network","pppoe","check_pppoe","apply_network_config_pppoe")end
function check_wan(c,t,o,c,c,c)r.register_secname_filter(t,o,{protocol={[n]="luci.data.network.check_protocol"},clone_mode={[n]="luci.data.network.check_clone_mode"},mac={[n]="luci.data.network.check_mac"}})return e.E_NONE
end
function check_static(a,t,c,a,a,a)r.register_secname_filter(t,c,{ip={[n]="luci.data.network.check_ip"},netmask={[n]="luci.data.network.check_netmask"},gateway={[n]="luci.data.network.check_gateway",[o]={0,8}},mtu={[n]="luci.data.network.check_mtu",[o]={576,1500,"static"}},dns_pri={[n]="luci.data.network.check_pridns"},dns_sec={[n]="luci.data.network.check_secdns"}})return e.E_NONE
end
function check_dhcp(a,t,c,a,a,a)r.register_secname_filter(t,c,{mtu={[n]="luci.data.network.check_mtu",[o]={576,1500,"dhcp"}},dns_mode={[n]="luci.phicomm.validator.check_bool"},dns_pri={[n]="luci.data.network.check_pridns"},dns_sec={[n]="luci.data.network.check_secdns"}})return e.E_NONE
end
function check_pppoe(a,t,c,a,a,a)r.register_secname_filter(t,c,{username={[n]="luci.data.network.check_username"},password={[n]="luci.data.network.check_password"},dial_mode={[n]="luci.data.network.check_dial_mode"},server={[n]="luci.data.network.check_server_name"},mtu={[n]="luci.data.network.check_mtu",[o]={576,1492,"pppoe"}},dns_mode={[n]="luci.phicomm.validator.check_bool"},dns_pri={[n]="luci.data.network.check_pridns"},dns_sec={[n]="luci.data.network.check_secdns"}})return e.E_NONE
end
function apply_network_config_wan(n,n,n,t,d,r)local n=require("luci.model.uci")local n=n.cursor()local a,o=a.get_welcome_config()local o=o.guide
if nil~=t.protocol and""~=t.protocol then
n:set("network","wan","proto",t.protocol)end
if nil~=t.clone_mode and""~=t.clone_mode then
n:set("network","wan","macoperate",tostring(tonumber(t.clone_mode)+1))end
local r=d.clone_mode or r.clone_mode
if r=="0"then
if nil~=t.source_mac and""~=t.source_mac then
n:set("network","wan","macaddr",t.source_mac)end
n:set("network","wan","ignore","1")elseif r=="1"then
if nil~=t.mac and""~=t.mac then
n:set("network","wan","mac_addr",t.mac)end
n:set("network","wan","ignore","0")else
n:set("network","wan","ignore","1")end
if o=="0"then
if t.protocol=="dhcp"then
local e=n:get("network","wan","dhcp_dns_mode")if e=="0"then
n:delete("network","wan","dns1")n:delete("network","wan","dns2")n:delete("network","wan","dns")n:set("network","wan","peerdns","1")else
local e=n:get("network","wan","dns1")local t=n:get("network","wan","dns2")or""local e=e.." "..t
n:set("network","wan","dns",e)n:set("network","wan","peerdns","0")end
local e=n:get("network","wan","ignore_mtu_change_pppoe")if e=="1"then
n:set("network","wan","mtu","1500")n:set("network","wan","ignore_mtu_change_pppoe","0")end
end
n:save("network")n:commit("network")n:apply("network",false,true)return e.E_NONE,{wait_time=c,_applied=true}else
n:save("network")n:commit("network")return e.E_NONE,{wait_time=2,_applied=false}end
end
function network_reloeded(e)if not e or not e.network or not e.network.wan then
return false
end
return e.network.wan["_applied"]end
function apply_network_config_static(n,n,n,i,o,r,d)local n=require("luci.model.uci")local n=n.cursor()local a,t=a.get_welcome_config()local a=t.guide
local t,t
local t={ip="ipaddr",netmask="netmask",gateway="gateway",mtu="mtu",dns_pri="static_dns1",dns_sec="static_dns2"}for e,r in pairs(i)do
if nil~=t[e]then
n:set("network","wan",t[e],r)end
end
local t=o.dns_pri or r.dns_pri
local r=o.dns_sec or r.dns_sec
local t=t
if nil~=r and""~=r then
t=t.." "..r
end
n:set("network","wan","dns",t)n:set("network","wan","peerdns","0")n:set("network","wan","ignore_mtu_change_pppoe","0")n:save("network")n:commit("network")if a=="0"then
if network_reloeded(d)then
return e.E_NONE,{wait_time=2}else
n:apply("network",false,true)return e.E_NONE,{wait_time=c}end
else
return e.E_NONE,{wait_time=2}end
end
function apply_network_config_dhcp(n,n,n,t,d,i,o)local n=require("luci.model.uci")local n=n.cursor()local a,r=a.get_welcome_config()local a=r.guide
local r,r
local r={mtu="mtu",dns_pri="dns1",dns_sec="dns2"}for e,t in pairs(t)do
if nil~=r[e]then
n:set("network","wan",r[e],t)end
end
n:set("network","wan","ignore_mtu_change_pppoe","0")local r=d.dns_mode or i.dns_mode
if r=="1"then
n:set("network","wan","peerdns","0")n:set("network","wan","dhcp_dns_mode","1")if nil~=t.dns_pri and""~=t.dns_pri then
n:set("network","wan","dns",t.dns_pri.." "..t.dns_sec)end
else
n:delete("network","wan","dns1")n:delete("network","wan","dns2")n:delete("network","wan","dns")n:set("network","wan","peerdns","1")n:set("network","wan","dhcp_dns_mode","0")end
n:save("network")n:commit("network")if a=="0"then
if network_reloeded(o)then
return e.E_NONE,{wait_time=2}else
n:apply("network",false,true)return e.E_NONE,{wait_time=c}end
else
return e.E_NONE,{wait_time=2}end
end
function apply_network_config_pppoe(n,n,n,t,i,_,d)local n=require("luci.model.uci")local n=n.cursor()local o,r=a.get_welcome_config()local o=r.guide
local r,r
local r={username="username",password="password",dial_mode="DiaMode",server="service",dns_pri="pppoedns1",dns_sec="pppoedns2"}for e,t in pairs(t)do
if nil~=r[e]then
n:set("network","wan",r[e],t)end
end
if nil~=t.mtu and""~=t.mtu then
n:set("network","wan","mtu",tostring(tonumber(t.mtu)+8))else
n:set("network","wan","mtu","1488")end
n:set("network","wan","ignore_mtu_change_pppoe","1")local r=i.dns_mode or _.dns_mode
if r=="1"then
n:set("network","wan","peerdns","0")n:set("network","wan","pppoe_dns_mode","1")if nil~=t.dns_pri and""~=t.dns_pri then
n:set("network","wan","dns",t.dns_pri.." "..t.dns_sec)end
else
n:delete("network","wan","pppoedns1")n:delete("network","wan","pppoedns2")n:delete("network","wan","dns")n:set("network","wan","peerdns","1")n:set("network","wan","pppoe_dns_mode","0")end
n:save("network")n:commit("network")if o=="0"then
if network_reloeded(d)then
return e.E_NONE,{wait_time=2}else
n:apply("network",false,true)return e.E_NONE,{wait_time=c}end
else
return e.E_NONE,{wait_time=2}end
end
function check_protocol(n,t,t,t)local t={"dhcp","pppoe","static"}for r,t in ipairs(t)do
if t==n then
return e.E_NONE
end
end
return e.E_INVWANMODE
end
function check_clone_mode(n,r,o,o)if not(t.check_num(n))then
return e.E_INVMACCLONEMODE
end
if 1==n or"1"==n then
if r.mac==""then
return e.E_MACCLONEBLANK
end
local n=t.check_mac(r.mac)if n~=e.E_NONE then
return n
end
end
return e.E_NONE
end
function check_mac(n,r,o,o)if 1==r.clone_mode or"1"==r.clone_mode then
if n==""then
return e.E_MACCLONEBLANK
end
local n=t.check_mac(n)if n==E_INVMACFMT then
return E_INVMACCLONEADDR
end
if n~=e.E_NONE then
return n
end
end
return e.E_NONE
end
function check_ip(n,d,r,a)local r=require("luci.controller.admin.lan")local r,o=r.get_lan_config()local r=o.ip
local c=o.netmask
local o=d.netmask or a.netmask
local a=t.check_ip(n)if a~=e.E_NONE then
return e.E_STATICIPILLEGAL
end
local c=t.check_same_network(r,n,c)local n=t.check_same_network(r,n,o)if c or n then
return e.E_NETLANSAME
end
return e.E_NONE
end
function check_netmask(n,r,r,r)local n=t.check_mask(n)if n~=e.E_NONE then
return e.E_STATICMASKILLEGAL
end
return e.E_NONE
end
function check_gateway(r,n,o,o)local o=t.check_ip(r)if o~=e.E_NONE then
return e.E_STATICGWILLEGAL
end
if t.check_ip(n.ip)==e.E_NONE and t.check_mask(n.netmask)==e.E_NONE then
local n=t.check_same_network(n.ip,r,n.netmask)if not n then
return e.E_STATICGWILLEGAL
end
end
if n.ip==r then
return e.E_STATICGWEQSTATICIP
end
return e.E_NONE
end
function check_mtu(r,a,a,a,c,o,n)if""==r then
if n=="static"then
return e.E_MTUSTATICBLANK
elseif n=="dhcp"then
return e.E_MTUDHCPBLANK
else
return e.E_MTUPPPOEBLANK
end
end
if not t.check_num_range(r,c,o)then
if n=="static"then
return e.E_INVMTUSTATIC
elseif n=="dhcp"then
return e.E_INVMTUDHCP
else
return e.E_INVMTUPPPOE
end
end
return e.E_NONE
end
function check_vpn_dns_mode(n,r,r,r)if""==n then
return e.E_NONE
end
local n=t.check_bool(n)if n~=e.E_NONE then
return e.E_INVDNSMODE
end
return e.E_NONE
end
function check_pridns(n,r,o,o)if r.dns_mode~="0"then
if""==n then
return e.E_FDNSIPBLANK
end
local t=t.check_ip(n)if t~=e.E_NONE then
return e.E_INVFDNSIP
end
if n==r.dns_sec then
return e.E_FDNSEQSDNS
end
end
return e.E_NONE
end
function check_secdns(n,r,o,o)if r.dns_mode~="0"then
if""==n then
return e.E_NONE
end
local t=t.check_ip(n)if t~=e.E_NONE then
return e.E_INVSDNSIP
end
if n==r.dns_pri then
return e.E_FDNSEQSDNS
end
end
return e.E_NONE
end
function check_username(n,t,t,t)if type(n)~="string"or""==n then
return e.E_PPPOENAMEBLANK
end
local n=#n
if n>32 or n<=0 then
return e.E_PPPOENAMELEN
end
return e.E_NONE
end
function check_password(n,t,t,t)if type(n)~="string"or""==n then
return e.E_PPPOEPWDBLANK
end
local t=#n
if t>32 or t<=0 then
return e.E_PPPOEPWDLEN
end
local r=127
for t=1,t do
local n=string.byte(n,t,t)if n>r then
return e.E_PPPOEPWDILLEGAL
end
end
return e.E_NONE
end
function check_dial_mode(n,t,t,t)local t={0,1,2,3,4,"0","1","2","3","4"}local r,r
for r,t in pairs(t)do
if t==n then
return e.E_NONE
end
end
return e.E_INVDIAGMODE
end
function check_server_name(n,n,n,n)return e.E_NONE
end
