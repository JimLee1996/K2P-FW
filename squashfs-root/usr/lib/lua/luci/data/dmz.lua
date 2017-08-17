local e=require("luci.phicomm.error")local i=require("luci.phicomm.validator")local l=require("luci.controller.ds")local c=l.filter_key.validator
local r=l.filter_key.args
module("luci.data.dmz",package.seeall)function index()register_secname_cb("firewall","dmz","check_dmz","apply_dmz_config")end
function check_dmz(n,r,i,n,n,n)l.register_secname_filter(r,i,{enable={[c]="luci.phicomm.validator.check_bool"},ip={[c]="luci.data.dmz.check_ip"}})return e.E_NONE
end
function check_ip(l,c,r,r)local c=c.enable
if c=="1"then
if""==l then
return e.E_INVDMZIPNULL
end
local c=i.check_ip(l)if c~=e.E_NONE then
return e.E_INVDMZIP
end
local r=require("luci.controller.admin.lan")local n,r=r.get_lan_config()local n=r.ip
local r=r.netmask
c=i.check_ip_mask(l,r)if c~=e.E_NONE then
return e.E_INVDMZIP
end
if l==n then
return e.E_INVDMZLANIP
end
local l=i.check_same_network(n,l,r)if not l then
return e.E_INVDMZGWLANIP
end
return e.E_NONE
else
return e.E_NONE
end
end
function apply_dmz_config(l,l,l,c,l,l)local l=require("luci.model.uci")local l=l.cursor()l:set("DMZ","DMZ","enable",c.enable)l:set("DMZ","DMZ","dmz_ip",c.ip)l:save("DMZ")l:commit("DMZ")l:apply("DMZ",false,true)return e.E_NONE,{wait_time=3}end
