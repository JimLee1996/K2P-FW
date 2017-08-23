local r=require("luci.phicomm.error")module("luci.controller.admin.page",package.seeall)function index()local e=node()if not e.target then
e.target=alias("pc")e.index=true
end
local e=entry({"pc"},call("pageStyle"))e.sysauth="admin"e.sysauth_authenticator="htmlauth"e.index=true
e=entry({"pc","login.htm"},template("pc/login"))e.sysauth=false
e.leaf=true
e=entry({"pc","userAgreement.htm"},template("pc/userAgreement"))e.sysauth=false
e.leaf=true
e=entry({"pc","guide.htm"},template("pc/guide"))e.sysauth=false
e.leaf=true
e=entry({"pc","setLgPwd.htm"},template("pc/setLgPwd"))e.sysauth=false
e.leaf=true
entry({"pc","guideNetworkSet.htm"},template("pc/guideNetworkSet")).leaf=true
entry({"pc","guideWifiSet.htm"},template("pc/guideWifiSet")).leaf=true
entry({"pc","menu.htm"},template("pc/menu")).leaf=true
entry({"pc","netState.htm"},template("pc/netState")).leaf=true
entry({"pc","wifiConfig.htm"},template("pc/wifiConfig")).leaf=true
entry({"pc","App.htm"},template("pc/App")).leaf=true
entry({"pc","modifyPwd.htm"},template("pc/modifyPwd")).leaf=true
entry({"pc","upgradeWgt.htm"},template("pc/upgradeWgt")).leaf=true
entry({"pc","timeReboot.htm"},template("pc/timeReboot")).leaf=true
register_keyword_data("time_reboot","config","get_reboot_config")e=entry({"h5"},call("pageStyle"))e.sysauth="admin"e.sysauth_authenticator="htmlauth"e.index=true
e=entry({"h5","login.htm"},template("h5/login"))e.sysauth=false
e.leaf=true
e=entry({"h5","userAgreement.htm"},template("h5/userAgreement"))e.sysauth=false
e.leaf=true
e=entry({"h5","guide.htm"},template("h5/guide"))e.sysauth=false
e.leaf=true
e=entry({"h5","setLgPwd.htm"},template("h5/setLgPwd"))e.sysauth=false
e.leaf=true
entry({"h5","guideNetworkSet.htm"},template("h5/guideNetworkSet")).leaf=true
entry({"h5","guideWifiSet.htm"},template("h5/guideWifiSet")).leaf=true
entry({"h5","menu.htm"},template("h5/menu")).leaf=true
entry({"h5","netState.htm"},template("h5/netState")).leaf=true
entry({"h5","devList.htm"},template("h5/devList")).leaf=true
entry({"h5","wifiConfig.htm"},template("h5/wifiConfig")).leaf=true
entry({"h5","App.htm"},template("h5/App")).leaf=true
entry({"h5","modifyPwd.htm"},template("h5/modifyPwd")).leaf=true
local e=entry({"scheme_upgrade"},call("response_scheme_upgrade"))e.sysauth=false
e.leaf=true
end
function pageStyle()return true end
function get_reboot_config(e)local e={enable="0",reboot_hour=0,reboot_minute=0}local t=require("luci.model.uci")local t=t.cursor()e.enable=t:get("timereboot","timereboot","enable")e.reboot_hour=t:get("timereboot","timereboot","hour")e.reboot_minute=t:get("timereboot","timereboot","minute")return r.E_NONE,e
end
function response_scheme_upgrade()local e=require("luci.http")local n=e.formvalue("type")local r,l="schemeupgrade","config"local t=require("luci.model.uci").cursor()local function o(r)local t=e.formvalue("callback")if not t or#t<0 then
e.status(404,"Access Forbidden.")e.close()else
local l=require("luci.json")local t=t.."("..l.encode(r)..")"e.prepare_content("text/javascript")e.write(t)e.close()end
end
if"get"==n then
local a=""local e={}e.fw_version=t:get("system","system","fw_ver")or"unknown"e.up_sw_ver=t:get(r,l,"sw_ver")or"unknown"e.up_desc=t:get(r,l,"sw_desc")or"unknown"a=t:get(r,l,"pubtime")or"unknown"if a~="unknown"then
e.up_pubtime=os.date("%c",a)end
o(e)elseif"set"==n then
local a=""local a=""local a={}local e=e.formvalue("wait_time")if not e or string.match(e,"[^0-9]")then
a.error_code=-10209
else
t:set(r,l,"repeattime",e)t:set(r,l,"up_scheme","10")t:commit(r)os.execute("schemeupgrade")if e~="0"then
t:set(r,l,"up_scheme","3")t:commit(r)local t=require("nixio")local r=t.fork()if r==0 then
t.nanosleep(tonumber(e),0)os.execute("schemeupgrade")end
end
a.error_code=0
end
o(a)else
e.status(404,"Access Forbidden.")e.close()end
end
