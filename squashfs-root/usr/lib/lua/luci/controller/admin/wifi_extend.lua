local a=require("luci.phicomm.error")module("luci.controller.admin.wifi_extend",package.seeall)function index()entry({"pc","wisp.htm"},template("pc/wisp")).leaf=true
entry({"pc","setExtend.htm"},template("pc/setExtend")).leaf=true
entry({"h5","wisp.htm"},template("h5/wisp")).leaf=true
entry({"h5","setExtend.htm"},template("h5/setExtend")).leaf=true
entry({"h5","apList.htm"},template("h5/apList")).leaf=true
register_keyword_data("wisp","config","get_wisp_conf")register_keyword_data("wisp","ap_list","get_ap_list")end
function get_wisp_conf(i)local i=require("ubus")local i=i.connect()local e=i:call("network.interface.wan","status",{})local i=require("phic")local l=i.get_wifi_iface_config("2.4G","ApCliEnable")or{"0"}local t=l[1]local l=i.get_wifi_iface_config("5G","ApCliEnable")or{"0"}local c=l[1]if t=="1"then
local e=i.get_wifi_iface_config("2.4G","ApCliBssidBak")or{""}apcli_bssid=e[1]local e=i.get_wifi_iface_config("2.4G","ApCliSsid")or{""}apcli_ssid=e[1]local e=i.get_wifi_iface_config("2.4G","ApCliAuthMode")or{"OPEN"}apcli_auth=e[1]local e=i.get_wifi_iface_config("2.4G","ApCliEncrypType")or{""}apcli_enc=e[1]local i=i.get_wifi_iface_config("2.4G","ApCliWPAPSK")or{""}apcli_pskkey=i[1]apcli_band="0"elseif c=="1"then
local e=i.get_wifi_iface_config("5G","ApCliBssidBak")or{""}apcli_bssid=e[1]local e=i.get_wifi_iface_config("5G","ApCliSsid")or{""}apcli_ssid=e[1]local e=i.get_wifi_iface_config("5G","ApCliAuthMode")or{"OPEN"}apcli_auth=e[1]local e=i.get_wifi_iface_config("5G","ApCliEncrypType")or{""}apcli_enc=e[1]local i=i.get_wifi_iface_config("5G","ApCliWPAPSK")or{""}apcli_pskkey=i[1]apcli_band="1"else
apcli_bssid=""apcli_ssid=""apcli_auth="OPEN"apcli_enc=""apcli_pskkey=""apcli_band=""end
if apcli_auth=="WPA2PSK"then
apcli_auth="WPA2-PSK"elseif apcli_auth=="WPAPSK"or apcli_auth=="WPA1PSK"then
apcli_auth="WPA-PSK"elseif apcli_auth=="WPA"then
apcli_auth="WPAENT"elseif apcli_auth=="WPAPSKWPA2PSK"or apcli_auth=="WPA1PSKWPA2PSK"then
apcli_auth="WAPWPA2-PSK"elseif apcli_auth=="OPEN"then
apcli_auth="OPEN"else
apcli_auth=apcil_auth
end
local p=e["proto"]local i=e["ipv4-address"]local n=(i and#i>0 and i[1].address)or"0.0.0.0"local l=nil
for e,i in ipairs(e["route"]or{})do
if i.target=="0.0.0.0"and i.mask==0 then
l=i.nexthop or"0.0.0.0"end
end
local i={enable=tostring(tonumber(t)+tonumber(c)),band=apcli_band,bssid=apcli_bssid,ssid=apcli_ssid,safe_mode=apcli_auth,encryption=apcli_enc,password=apcli_pskkey,protocol=p,ip=n,gateway=l}return a.E_NONE,i
end
function get_ap_list()local l=require("apcli")local function t(i)if"WPAPSKWPA2PSK"==i or"WPA1PSKWPA2PSK"==i then
return"WPAWPA2-PSK"elseif"WPAPSK"==i or"WPA1PSK"==i then
return"WPA-PSK"elseif"WPA2PSK"==i then
return"WPA2-PSK"elseif"WPA"==i then
return"WPAENT"elseif"OPEN"==i then
return"OPEN"else
return i
end
end
local function c(i)if 1==i then
return"0"elseif 2==i then
return"1"end
end
local i,e=nil,{}local i=l.get_ap_list("2.4&5")for l,i in ipairs(i)do
e[#e+1]={bssid=i.bssid,ssid=i.ssid,safe_mode=t(i.authmode),encryption=i.security,signal=i.quality,channel=i.channel,band=c(i.aptype)}end
local i=require("luci.fs")i.unlink("/tmp/wisp/aplist")i.unlink("/tmp/wisp/count")i.unlink("/tmp/wisp/timestamp")i.rmdir("/tmp/wisp")return a.E_NONE,e
end
