local e=require("luci.phicomm.error")local n=require("luci.controller.ds")local d=n.filter_key.validator
local s=n.filter_key.args
module("luci.data.ddns",package.seeall)function index()register_secname_cb("ddns","config","check_ddns","apply_ddns_config")end
function check_ddns(i,s,r,i,i,i)n.register_secname_filter(s,r,{enable={[d]="luci.phicomm.validator.check_bool"},provider={[d]="luci.data.ddns.check_ddns_provider"},user={[d]="luci.data.ddns.check_ddns_user"},password={[d]="luci.data.ddns.check_ddns_pwd"},domain={[d]="luci.data.ddns.check_ddns_domain"}})return e.E_NONE
end
function check_ddns_provider(n,d,d,d)local d
local d={"dynupdate.no-ip.com","dyndns.org","oray.com","pubyun.com"}for s,d in ipairs(d)do
if d==n then
return e.E_NONE
end
end
return e.E_INVDDNSSVR
end
function check_ddns_user(d,n,n,n)if""==d then
return e.E_DDNSNAMEBLANK
end
if type(d)~="string"then
return e.E_INVDDNSNAME
end
if#d<0 or#d>64 then
return e.E_INVDDNSNAME
else
return e.E_NONE
end
end
function check_ddns_pwd(d,n,n,n)if""==d then
return e.E_DDNSPWDBLANK
end
if type(d)~="string"then
return e.E_INVDDNSPWD
end
if#d<0 or#d>64 then
return e.E_INVDDNSPWD
end
for n=1,#d do
local d=string.byte(d,n,n)if d>127 then
return e.E_INVDDNSPWD
end
end
return e.E_NONE
end
function check_ddns_domain(d,n,n,n)local n=require("luci.phicomm.validator")if""==d then
return e.E_DDNSHOSTBLANK
end
if not n.check_domain(d)then
return e.E_INVDDNSHOST
end
return e.E_NONE
end
function apply_ddns_config(n,n,n,d,n,n)require("luci.sys")local n=require("luci.model.uci").cursor()if nil~=d.enable and""~=d.enable then
n:set("ddns","myddns","enabled",d.enable)else
n:set("ddns","myddns","enabled","0")end
if nil~=d.provider and""~=d.provider then
n:set("ddns","myddns","service_name",d.provider)else
n:set("ddns","myddns","service_name","")end
if nil~=d.user and""~=d.user then
n:set("ddns","myddns","username",d.user)else
n:set("ddns","myddns","username","")end
if nil~=d.password and""~=d.password then
n:set("ddns","myddns","password",d.password)else
n:set("ddns","myddns","password","")end
if nil~=d.domain and""~=d.domain then
n:set("ddns","myddns","domain",d.domain)else
n:set("ddns","myddns","domain","")end
n:save("ddns")n:commit("ddns")luci.sys.exec("/etc/init.d/ddns enable")if n:get("ddns","myddns","enabled")=="1"then
luci.sys.exec("/etc/init.d/ddns restart")else
luci.sys.exec("/etc/init.d/ddns stop")end
return e.E_NONE
end
