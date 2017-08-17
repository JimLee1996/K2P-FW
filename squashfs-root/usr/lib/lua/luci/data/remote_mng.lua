local e=require("luci.phicomm.error")local n=require("luci.phicomm.validator")local t=require("luci.controller.ds")local r=t.filter_key.validator
local o=t.filter_key.args
module("luci.data.remote_mng",package.seeall)function index()register_secname_cb("firewall","remote_manager","check_remote","apply_remote_config")end
function check_remote(l,o,n,l,l,l)t.register_secname_filter(o,n,{enable={[r]="luci.phicomm.validator.check_bool"},ip={[r]="luci.data.remote_mng.check_ip"},port={[r]="luci.data.remote_mng.check_port"}})return e.E_NONE
end
function apply_remote_config(r,r,r,t,r,r)local r=require("luci.model.uci")local r=r.cursor()if t.enable=="0"then
r:set("remote","remote","remote_enable","0")else
r:set("remote","remote","remote_enable",t.enable)r:set("remote","remote","remote_ip",t.ip)r:set("remote","remote","remote_port",t.port)end
r:commit("remote")luci.sys.call("/etc/init.d/remote enable > /dev/null; /etc/init.d/remote restart > /dev/null")return e.E_NONE,{wait_time=3}end
function check_ip(r,t,t,t)if""==r then
return e.E_RMTIPBLANK
end
if"255.255.255.255"==r then
return e.E_NONE
end
local t=n.check_ip(r)if t~=e.E_NONE then
return e.E_INVRMTIP
end
local t=require("luci.controller.admin.lan")local o,t=t.get_lan_config()local o=t.ip
local t=t.netmask
local r=n.check_same_network(o,r,t)if r then
return e.E_INVRMTLANIP
end
return e.E_NONE
end
function check_port(r,t,t,t)if""==r then
return e.E_RMTPORTBLANK
end
if not n.check_num_range(r,1,65535)then
return e.E_INVRMTPORT
end
local t=require("luci.controller.admin.port_forward")local n,t=t.get_forward_list()for n,t in ipairs(t)do
if r>=t.extern_port_start and r<=t.extern_port_end then
return e.E_INVRMTPFDPORT
end
end
return e.E_NONE
end
