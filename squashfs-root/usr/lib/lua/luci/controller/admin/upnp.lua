local o=require("luci.phicomm.error")module("luci.controller.admin.upnp",package.seeall)function index()entry({"pc","upnp.htm"},template("pc/upnp")).leaf=true
register_keyword_data("upnp","config","get_upnp_config")register_keyword_data("upnp","upnp_list","get_upnp_list")end
function get_upnp_config()local e={}local l=require("luci.model.uci")local l=l.cursor()e.enable=l:get("UPnP","config","enable")return o.E_NONE,e
end
function get_upnp_list()local e=require("luci.model.uci")local e=e.cursor()local r=require"luci.util"local n={list={}}local e=e:get("upnpd","config","upnp_lease_file")if not e then
e="/var/upnp.leases"end
if e then
local e=io.open(e,"r")if e then
local l=1
while true do
local e=e:read("*l")if not e then
break
end
local e=r.split(e,":")if not e or#e~=6 then
t={}break
end
n.list[l]={protocol=e[1],external_port=e[2],ip=e[3],internal_port=e[4],status='1',descript=e[6]}l=l+1
end
end
end
return o.E_NONE,n
end
