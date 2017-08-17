local e=require("luci.phicomm.error")local o=require("luci.phicomm.validator")local n=require("luci.controller.ds")local r=n.filter_key.validator
local t=n.filter_key.args
module("luci.data.port_forward",package.seeall)function index()register_secname_cb("port_forward","config","check_forward_config","apply_forward_config")register_secname_cb("port_forward","forward_list","check_forward_list","apply_forward_list")end
function check_forward_config(a,o,t,a,a,a)n.register_secname_filter(o,t,{enable={[r]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function apply_forward_config(r,r,r,n,r,r)local r=require("luci.model.uci")local r=r.cursor()r:set("appportfwd","config","enable",n.enable)r:save("appportfwd")r:commit("appportfwd")r:apply("appportfwd",false,true)return e.E_NONE
end
function check_forward_list(c,a,o,c,c,c)n.register_secname_filter(a,o,{id={[r]="luci.data.port_forward.check_id"},name={[r]="luci.data.port_forward.check_name"},ip={[r]="luci.data.port_forward.check_ip"},extern_port_start={[r]="luci.data.port_forward.check_extern_start",[t]={1,65535}},extern_port_end={[r]="luci.data.port_forward.check_extern_end",[t]={1,65535}},inner_port_start={[r]="luci.data.port_forward.check_inner_start",[t]={1,65535}},inner_port_end={[r]="luci.data.port_forward.check_inner_end"},protocol={[r]="luci.data.port_forward.check_protocol"}})return e.E_NONE
end
function apply_forward_list(o,n,n,r,n,n)local n=require("luci.model.uci")local n=n.cursor()local t
if o~="del"then
if tonumber(r.id)then
n:foreach("appportfwd","setting",function(e)if e.id==r.id then
t=e[".name"]return
end
end)else
math.randomseed(tostring(os.time()):reverse():sub(1,6))r.id=tostring(math.random())t=n:add("appportfwd","setting")end
local o={id="id",name="name",ip="serverip",protocol="proto"}local e,e
for e,r in pairs(r)do
if nil~=o[e]then
n:set("appportfwd",t,o[e],r)end
end
local e,o
if r.extern_port_start==r.extern_port_end then
e=r.extern_port_start
else
e=r.extern_port_start.."-"..r.extern_port_end
end
if r.inner_port_start==r.inner_port_end then
o=r.inner_port_start
else
o=r.inner_port_start.."-"..r.inner_port_end
end
n:set("appportfwd",t,"exterport",e)n:set("appportfwd",t,"interport",o)local e={["1"]="tcp",["2"]="udp",["3"]="tcp+udp"}n:set("appportfwd",t,"proto",e[r.protocol]or"")else
if tonumber(r.id)then
n:foreach("appportfwd","setting",function(e)if e.id==r.id then
t=e[".name"]return
end
end)end
n:delete("appportfwd",t)end
n:save("appportfwd")n:commit("appportfwd")n:apply("appportfwd",false,true)return e.E_NONE
end
function check_id(r,r,r,r)return e.E_NONE
end
function check_name(r,n,n,n)if"string"~=type(r)then
return e.E_INVPFDNAME
end
if#r<1 or#r>32 then
return e.E_INVPFDNAMELEN
end
return e.E_NONE
end
function check_ip(r,n,n,n)local n=o.check_ip(r)if n~=e.E_NONE then
return e.E_INVPFDIP
end
local t=require("luci.controller.admin.lan")local a,t=t.get_lan_config()local a=t.ip
local t=t.netmask
n=o.check_ip_mask(r,t)if n~=e.E_NONE then
return e.E_INVPFDIP
end
if a==r then
return e.E_INVPFDLANIP
end
local r=o.check_same_network(a,r,t)if not r then
return e.E_INVPFDGWLANIP
end
return e.E_NONE
end
function check_extern_port(a,n)local r=tonumber(n.extern_port_start)local e=tonumber(n.extern_port_end)local o=n.protocol
local t,t
if r==e then
for a,t in ipairs(a)do
if t.id~=n.id and(o=="3"or t.protocol=="3"or t.protocol==o)then
local n=tonumber(t.extern_port_start)local t=tonumber(t.extern_port_end)if n<=r and t>=e then
return false
end
end
end
else
for a,t in ipairs(a)do
if t.id~=n.id and(o=="3"or t.protocol=="3"or t.protocol==o)then
local n=tonumber(t.extern_port_start)local t=tonumber(t.extern_port_end)if(n>=r and t<=e)or(n<=r and t>=r)or(n<=e and t>=e)or(n<=r and t>=e)then
return false
end
end
end
end
return true
end
function check_extern_start(n,a,c,d,r,t)if not o.check_num_range(n,r,t)then
return e.E_INVPFDSTFDCL
end
local c=a.extern_port_end
local n=tonumber(n)local _=tonumber(c)local i=require("luci.controller.admin.remote_mng")local l,i=i.get_remote_manager_info()local i=i.port
local i=tonumber(i)if i>=n and i<=_ then
return e.E_INVPFDFDRMSV
end
if o.check_num_range(c,r,t)then
if n>_ then
return e.E_INVPFDSTENCL
end
end
if(not check_extern_port(d,a))then
return e.E_INVPFDNOFDCL
end
return e.E_NONE
end
function check_extern_end(n,a,a,a,r,t)if not o.check_num_range(n,r,t)then
return e.E_INVPFDENFDCL
end
return e.E_NONE
end
function check_inner_start(r,n,t,f,p,l)local a=n.extern_port_start
local c=n.extern_port_end
local t=n.inner_port_end
local _=tonumber(r)local d=tonumber(t)local i=n.protocol
local u,u
if a~=c then
if r~=t then
if a~=r or c~=t then
return e.E_INVSVPRTEQCLPRT
end
end
else
if r~=t then
return e.E_INVSVPRTCLPRT
end
end
if r==t then
if not o.check_num_range(r,p,l)then
return e.E_INVPFDSTFDSV
end
for t,r in ipairs(f)do
if r.id~=n.id and(i=="3"or r.protocol=="3"or r.protocol==i)then
local n=tonumber(r.inner_port_start)local r=tonumber(r.inner_port_end)if n<=_ and r>=d then
return e.E_INVPFDNOFDSV
end
end
end
end
return e.E_NONE
end
function check_inner_end(r,r,r,r,r,r)return e.E_NONE
end
function check_protocol(r,n,n,n)if"string"~=type(r)then
return e.E_INVPFDAM
end
if#r<=0 then
return e.E_INVPFDAMNULL
end
if#r==1 then
if r<'1'or r>'3'then
return e.E_INVPFDAM
end
end
return e.E_NONE
end