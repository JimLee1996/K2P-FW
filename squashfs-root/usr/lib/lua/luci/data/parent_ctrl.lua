local e=require("luci.phicomm.error")local n=require("luci.phicomm.validator")local c=require("luci.controller.ds")local t=c.filter_key.validator
module("luci.data.parent_ctrl",package.seeall)function index()register_secname_cb("parent_ctrl","config","check_parent_config","apply_parent_config")register_secname_cb("parent_ctrl","parent_list","check_parent_list","apply_parent_list")end
function check_parent_config(l,n,r,l,l,l)c.register_secname_filter(n,r,{enable={[t]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function check_parent_list(l,n,r,l,l,l)c.register_secname_filter(n,r,{id={[t]="luci.data.parent_ctrl.check_id"},name={[t]="luci.data.parent_ctrl.check_name"},mac={[t]="luci.data.parent_ctrl.check_mac"},cycle={[t]="luci.data.parent_ctrl.check_cycle"},start_time={[t]="luci.data.parent_ctrl.check_start_time"},end_time={[t]="luci.data.parent_ctrl.check_end_time"}})return e.E_NONE
end
function check_id(t,t,t,t)return e.E_NONE
end
function check_name(t,n,n,n)if"string"~=type(t)then
return e.E_PARENT_RULENAME_ILLEGAL
end
if""==t then
return e.E_PARENT_RULENAME_BLANK
end
if#t>32 then
return e.E_CLIENT_RULENAME_LEN
end
return e.E_NONE
end
function check_mac(t,c,c,c)local t=n.check_mac(t)if t~=e.E_NONE then
return e.E_PARENT_MAC_ILLEGAL
end
return e.E_NONE
end
function check_cycle(t,t,t,t)return e.E_NONE
end
function check_start_time(t,c,c,c)if not n.check_num_range(t,0,86400)then
return e.E_START_TIME_ILLEGAL
end
return e.E_NONE
end
function check_end_time(t,c,r,r)if not n.check_num_range(t,0,86400)then
return e.E_END_TIME_ILLEGAL
end
if tonumber(t)<=tonumber(c.start_time)then
return e.E_END_LESS_START
end
return e.E_NONE
end
function apply_parent_config(t,t,t,n,t,t)local t=require("luci.model.uci")local t=t.cursor()t:set("parentctl","config","enabled",n.enable)t:save("parentctl")t:commit("parentctl")if n.enable=="1"then
luci.sys.call("/etc/init.d/parentctl enable > /dev/null; /etc/init.d/parentctl start > /dev/null")else
luci.sys.call("/etc/init.d/parentctl disable > /dev/null; /etc/init.d/parentctl stop > /dev/null")end
return e.E_NONE
end
function freshruleindex()local t=0
local e=require("luci.model.uci")local e=e.cursor()e:foreach("parentctl","rule",function(n)t=t+1
e:set("parentctl",n[".name"],"ruleindex",t)end)e:commit("parentctl")end
function apply_parent_list(r,t,t,n,t,t)local t=require("luci.model.uci")local t=t.cursor()local c=require("luci.util")local c=""if r~="del"then
local r=""local e=1
while true do
_,e=string.find(tostring(n.cycle),"1",e)if e==nil then
break
else
if r==""then
r=tostring(e)else
r=r..","..e
end
e=e+1
end
end
local e,l
e=math.floor(tonumber(n.start_time)/3600)l=(n.start_time-e*3600)/60
local i=e..":"..l
e=math.floor(tonumber(n.end_time)/3600)l=(n.end_time-e*3600)/60
local a=e..":"..l
if tonumber(n.id)then
t:foreach("parentctl","rule",function(e)if e.ruleindex==n.id then
c=e[".name"]return
end
end)else
c=t:add("parentctl","rule")end
local e={mac="src_mac",}local l,l
for n,r in pairs(n)do
if nil~=e[n]then
t:set("parentctl",c,e[n],r)end
end
local l=string.gsub(n.mac,":","_")if t:get("common_host",l,"hostname")==nil then
local e=n.name or nil
if nil==e then
t:set_confdir("/var/state")e=t:get("base_device",l,"alias")t:set_confdir("/etc/config")end
t:section("common_host","host",l,{hostname=e})t:commit("common_host")end
t:set("parentctl",c,"start_time",i)t:set("parentctl",c,"stop_time",a)t:set("parentctl",c,"weekdays",r)else
for n in string.gmatch(n.id,"(%d+)|*")do
t:foreach("parentctl","rule",function(e)if e.ruleindex==n then
c=e[".name"]return
end
end)t:delete("parentctl",c)end
end
t:save("parentctl")t:commit("parentctl")freshruleindex()luci.sys.call("/etc/init.d/parentctl enable > /dev/null; /etc/init.d/parentctl start > /dev/null")return e.E_NONE
end
