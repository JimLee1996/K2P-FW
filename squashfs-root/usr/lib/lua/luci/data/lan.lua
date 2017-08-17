local e=require("luci.phicomm.error")local n=require("luci.phicomm.validator")local c=require("luci.controller.ds")local l=c.filter_key.validator
local t=c.filter_key.args
module("luci.data.lan",package.seeall)function index()register_secname_cb("network","lan","check_lan","apply_lan_config")end
function check_lan(a,n,t,a,a,a)c.register_secname_filter(n,t,{ip={[l]="luci.data.lan.check_ip"},netmask={[l]="luci.data.lan.check_mask"}})return e.E_NONE
end
function check_wan_lan_confilict(t,a)local c=require("luci.controller.admin.network")local c,l=c.get_wan_status()local c=l.ip
local l=l.netmask
if n.check_ip(c)==e.E_NONE and n.check_mask(l)==e.E_NONE then
local a=n.check_same_network(c,t,a)local e=n.check_same_network(c,t,l)if a or e then
return true
end
end
return false
end
function check_ip(l,t,c,a)local c=n.check_ip(l)local t=t.netmask or a.netmask
if c==e.E_NONE then
c=n.check_ip_mask(l,t)end
if c~=e.E_NONE then
return e.E_INVLANIP
end
c=check_wan_lan_confilict(l,t)if c then
return e.E_COMFLICTNET
end
return e.E_NONE
end
function check_mask(c,l,t,t)local n=n.check_mask(c)if n~=e.E_NONE then
return e.E_INVLANMASK
end
n=check_wan_lan_confilict(l.ip,c)if n then
return e.E_COMFLICTNET
end
return e.E_NONE
end
function apply_lan_config(n,n,n,l,n,t)local n=require("luci.model.uci")local n=n.cursor()local c=l.ip
local i=l.netmask or t.netmask
local t=n:get("network","lan","macaddr")local l
n:foreach("dhcp","host",function(e)if e.mac==t then
l=e
end
end)if not l then
n:section("dhcp","host",nil,{ip=c,mac=t})else
l.ip=c
n:tset("dhcp",l[".name"],l)end
local l=require("nixio").bit
nm3,nm2,nm1,nm0=string.match(i,"(%d+)%.(%d+)%.(%d+)%.(%d+)")ip3,ip2,ip1,ip0=string.match(c,"(%d+)%.(%d+)%.(%d+)%.(%d+)")local t=l.band(tonumber(nm0),tonumber(ip0))+1
local a=l.bxor(tonumber(nm0),255)-1
local r=t+a-1
local l=n:get_all("dhcp","lan")if tonumber(l.start)<t or(tonumber(l.start)+tonumber(l.limit)-1)>r then
l.start=t
l.limit=a
end
n:tset("dhcp","lan",l)n:save("dhcp")n:commit("dhcp")n:set("network","lan","ipaddr",c)n:set("network","lan","netmask",i)luci.sys.call("sed -i -e 's/\\(.*\\) \\(phicomm.me\\)/%s \\2/' /etc/hosts"%c)luci.sys.call("sed -i -e 's/\\(.*\\) \\(p.to\\)/%s \\2/' /etc/hosts"%c)n:save("network")n:commit("network")n:apply("network",false,true)return e.E_NONE,{wait_time=28}end
