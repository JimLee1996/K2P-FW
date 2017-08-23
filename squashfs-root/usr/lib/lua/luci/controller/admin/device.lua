local e=require("luci.phicomm.error")module("luci.controller.admin.device",package.seeall)function index()entry({"pc","routerInfo.htm"},template("pc/routerInfo")).leaf=true
register_keyword_data("welcome","config","get_welcome_config")register_keyword_data("device","info","get_device_info")register_keyword_data("security","status","get_security_status")local e=node("system")e.target=firstchild()e.sysauth="admin"e.sysauth_authenticator="htmlauth"e.index=true
entry({"system","reboot"},call("system_reboot")).leaf=true
entry({"system","reset"},call("system_reset")).leaf=true
end
function get_welcome_config()local t=require("luci.model.uci")local t=t.cursor()local t={guide=t:get("luci","main","guide"),language=t:get("luci","main","lang"),agreement=t:get("luci","main","agreement")}return e.E_NONE,t
end
function get_device_info()require("luci.sys")local t={}local r=require("luci.model.uci")local r=r.cursor()t.uptime=luci.sys.uptime()t.hw_ver=r:get("system","system","hw_ver")or"unknown"t.sw_ver=r:get("system","system","fw_ver")or"unknown"t.model=r:get("system","system","hostname")or"unknown"t.mac=string.upper(r:get("network","wan","macaddr")or"00:00:00:00:00:00")t.hw_id=r:get("dev_info","dev_info","hw_id")or"unknown"t.product_id=r:get("dev_info","dev_info","product_id")or"unknown"t.domain=r:get("system","system","domain")or"p.to"return e.E_NONE,t
end
function get_security_status()local t=require"luci.model.uci"local t=t.cursor()local o={}local t=0
local r=require"luci.data.guide"local r=r.get_account().pwd
local n=require"luci.base64"r=n.decode(r)if string.find(r,"%l")then
t=t+1
end
if string.find(r,"%u")then
t=t+1
end
if string.find(r,"%d")then
t=t+1
end
if string.find(r,"%W")then
t=3
end
o.safety=tostring(t)return e.E_NONE,o
end
function system_reboot()local t=require("luci.http")local r={}r[e.ERR_CODE]=e.E_NONE
t.write_json(r)t.close()os.execute("reboot")return e.E_NONE
end
function system_reset()local r=require("luci.http")local t={}t[e.ERR_CODE]=e.E_NONE
r.write_json(t)r.close()os.execute("jffs2reset -y & reboot")return e.E_NONE
end
