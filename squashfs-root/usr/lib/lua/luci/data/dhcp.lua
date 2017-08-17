local e=require("luci.phicomm.error")local t=require("luci.phicomm.validator")local o=require("luci.controller.ds")local n=o.filter_key.validator
local c=o.filter_key.args
local _=require("luci.phicomm.lib.bit").bit
module("luci.data.dhcp",package.seeall)function index()register_secname_cb("dhcpd","config","check_dhcp","apply_dhcp")register_secname_cb("dhcpd","bind_list","check_bind_list","apply_bind_list")end
function check_dhcp(l,t,c,l,l,l)o.register_secname_filter(t,c,{enable={[n]="luci.phicomm.validator.check_bool"},pool_start={[n]="luci.data.dhcp.check_pool_start"},pool_end={[n]="luci.data.dhcp.check_pool_end"}})return e.E_NONE
end
function apply_dhcp(n,n,n,i,n,l)local n=require("luci.model.uci")local c=n.cursor()local n=c:get_all("dhcp","lan")local t=tonumber(i.pool_start or l.pool_start)local o=tonumber(i.pool_end or l.pool_end)n.dynamicdhcp=i.enable or l.enable
n.start=t
if t>o then
n.limit=t-o+1
else
n.limit=o-t+1
end
c:tset("dhcp","lan",n)c:save("dhcp")c:commit("dhcp")c:apply("dhcp",false,true)return e.E_NONE,{wait_time=3}end
function check_pool_start(c,n,t,t)return check_pool(c,n,e.E_DHCPPOOLSTART)end
function check_pool_end(n,c,t,t)return check_pool(n,c,e.E_DHCPPOOLEND)end
function check_pool(l,n,o)local r,r,r,c,i=string.match(n.network_address,"(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)")local c=tonumber(c)local i=tonumber(i)local i=2^(32-i)-2
if t.check_num_range(l,1+c,i+c)then
if t.check_num(n.pool_start)then
if t.check_num(n.pool_end)then
local c=tonumber(n.pool_start)local n=tonumber(n.pool_end)if c>n then
return e.E_POOLSTARTGRATEREND
end
else
return e.E_DHCPPOOLEND
end
else
return e.E_DHCPPOOLSTART
end
else
return o
end
return e.E_NONE
end
function check_bind_list(l,c,t,l,l,l)o.register_secname_filter(c,t,{name={[n]="luci.data.dhcp.check_name"},ip={[n]="luci.data.dhcp.check_ip"},mac={[n]="luci.data.dhcp.check_mac"}})return e.E_NONE
end
function apply_bind_list(t,n,n,c,n,n)local n=require("luci.model.uci")local n=n.cursor()local i=c.id
local l=c.mac
local function r(c)local e
n:foreach("dhcp","host",function(n)if n.mac==c then
e=n
end
end)return e
end
local function a(e,c)n:section("common_host","host",e,{hostname=c})n:save("common_host")n:commit("common_host")end
if o.METHOD_ADD==t then
local t=r(l)if t then
return e.E_DHCPD_CONFLICT_MAC
else
a(string.gsub(l,":","_"),c.name or"unknown")n:section("dhcp","host",nil,{ip=c.ip,mac=c.mac})n:save("dhcp")n:commit("dhcp")end
elseif o.METHOD_DELETE==t then
local c=r(l)if not c then
return e.E_ENTRYNOTEXIST
else
n:delete("dhcp",c[".name"])n:save("dhcp")n:commit("dhcp")end
elseif o.METHOD_MODIFY==t then
local t=r(string.gsub(i,"_",":"))if not t then
return e.E_ENTRYNOTEXIST
else
t.ip=c.ip
t.mac=c.mac
n:tset("dhcp",t[".name"],t)n:save("dhcp")n:commit("dhcp")local e=string.gsub(l,":","_")if i~=e then
n:section("common_host","host",e,{hostname=c.name})n:save("common_host")n:commit("common_host")else
a(i,c.name or"unknown")end
end
else
return e.E_INVARG
end
n:apply("dhcp",false,true)return e.E_NONE,{wait_time=3}end
function check_name(n,c,c,c)if"string"~=type(n)then
return e.E_DEVMNG_RNM
end
if 0==#n or#n>32 then
return e.E_DEVMNG_RNM
end
return e.E_NONE
end
function check_ip(n,r,c,i)local c=require("luci.controller.admin.lan")local o,c=c.get_lan_config()local o=c.ip
local l=c.netmask
local c=t.check_ip(n)if e.E_NONE~=c then
return e.E_INVIP
end
local o=t.trans_ip(o)local c=t.trans_ip(n)local t=t.trans_ip(l)if _:bit_and(o,t)~=_:bit_and(c,t)then
return e.E_DHCPD_INVIP
end
if o==c then
return e.E_DHCPD_IP_LANIP
end
for t,c in ipairs(i)do
if c.id~=r.id then
if c.ip==n then
return e.E_DHCPD_CONFLICT_IP
end
end
end
return e.E_NONE
end
function check_mac(n,l,c,o)local c=t.check_mac(n)if e.E_NONE~=c then
return c
end
for t,c in ipairs(o)do
if c.id~=l.id then
if string.lower(c.mac)==string.lower(n)then
return e.E_DHCPD_CONFLICT_MAC
end
end
end
return e.E_NONE
end
