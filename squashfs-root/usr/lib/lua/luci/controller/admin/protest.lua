local c=require("luci.phicomm.error")module("luci.controller.admin.protest",package.seeall)function index()local e=node("protest")e.target=firstchild()e.sysauth=false
e.index=true
entry({"protest","info"},call("get_info")).leaf=true
end
function get_info()local t=require("luci.http")local e=require("luci.model.uci")local o=e.cursor()local l={}l["module"]={}l["module"]["protest"]={}local e={}local r="0"e.sw_ver=o:get("system","system","fw_ver")or""e.mac_wan=luci.util.exec("eth_mac r wan")or"00:00:00:00:00:00"e.mac_lan=luci.util.exec("eth_mac r lan")or"00:00:00:00:00:00"e.mac_2G=luci.util.exec("eth_mac r wlan_2")or"00:00:00:00:00:00"e.channel=luci.util.exec('iwconfig ra0 | grep Channel | cut -d "=" -f 2 | cut -d " " -f 1')or""o:foreach("wireless","wifi-iface",function(e)if e.ifname=="ra0"then
wifi_2g=e
return
end
end)if wifi_2g~=nil then
e.ssid_2G=wifi_2g.ssid or""else
e.ssid_2G=""end
local o=luci.util.exec("ps | grep telnetd | wc -l")if 3<tonumber(o)then
e.telnet_status="on"else
e.telnet_status="off"end
local o=require("luci.controller.admin.device")local i,o=o.get_welcome_config()local o=o.guide
e.reset_flag=o or""if e.sw_ver==""or e.channel==""or e.ssid_2G==""or e.reset_flag==""or e.mac_wan=="00:00:00:00:00:00"or e.mac_lan=="00:00:00:00:00:00"or e.mac_2G=="00:00:00:00:00:00"then
r="-1"end
l["module"]["protest"]["info"]=e
l["module"]["protest"]["error_code"]=r
t.write_json(l)t.close()return c.E_NONE
end
