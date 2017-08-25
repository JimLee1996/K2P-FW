local o=require("luci.phicomm.error")local l=require("luci.model.uci")module("luci.controller.admin.wireless",package.seeall)function index()entry({"pc","wifiConfig.htm"},template("pc/wifiConfig")).leaf=true
entry({"h5","wifiConfig.htm"},template("h5/wifiConfig")).leaf=true
register_keyword_data("wireless","smart_connect","get_smart_connect")register_keyword_data("wireless","wifi_2g_config","get_wifi_2g_config")register_keyword_data("wireless","wifi_2g_status","get_wifi_2g_status")register_keyword_data("wireless","wifi_5g_config","get_wifi_5g_config")register_keyword_data("wireless","wifi_5g_status","get_wifi_5g_status")end
local e=require"phic"local c=e.default_2g_wireless_ifname()[1]local d=e.default_5g_wireless_ifname()[1]function get_smart_connect(e)local e={enable="0"}return o.E_NONE,e
end
function get_wifi_2g_config(i)local i={mu_mimo="1",beamforming="1",power="1"}local l=l.cursor()local n
l:foreach("wireless","wifi-iface",function(e)if e.ifname==c then
n=e
return
end
end)if n~=nil then
i={ssid=n.ssid or"",password=n.key or"",hidden=n.hidden or""}else
i={ssid="",password="",hidden=""}end
local l=n.disabled
local n={["0"]="1",["1"]="0"}i.enable=n[l]or""i.channel=e.get_wifi_device_config("2.4G","channel")and e.get_wifi_device_config("2.4G","channel")[1]or""i.ap_isolate=e.get_wifi_device_config("2.4G","noforward")and e.get_wifi_device_config("2.4G","noforward")[1]or""local l=e.get_wifi_device_config("2.4G","wifimode")and e.get_wifi_device_config("2.4G","wifimode")[1]or""local n={["9"]="0",["0"]="1",["6"]="2"}i.mode=n[l]or"1"local e=e.get_wifi_device_config("2.4G","bw")and e.get_wifi_device_config("2.4G","bw")[1]or""local n={["0"]="0",["2"]="1",["1"]="2"}i.band_width=n[e]or""local e=0
local n=i.password
if string.find(n,"%l")then
e=e+1
end
if string.find(n,"%u")then
e=e+1
end
if string.find(n,"%d")then
e=e+1
end
if string.find(n,"%W")then
e=3
end
i.safety=tostring(e)return o.E_NONE,i
end
function get_wifi_2g_status(i)require("luci.util")local i={}local n={}local d=l.cursor()local l=e.get_wifi_device_config("2.4G","type")and e.get_wifi_device_config("2.4G","type")[1]or""d:foreach("wireless","wifi-iface",function(e)if e.device==l and e.ifname==c then
n=e
return
end
end)if n~=nil then
i.ssid=n.ssid or""else
i.ssid=""end
local l=n.encryption or"none"if string.sub(l,1,4)=="none"then
i.safe_mode="0"elseif string.sub(l,1,4)=="psk+"then
i.safe_mode="WPA-PSK"elseif string.sub(l,1,5)=="psk2+"then
ressult.safe_mode="WPA2-PSK"elseif string.sub(l,1,10)=="psk-mixed+"then
i.safe_mode="WPA-PSK/WPA2-PSK"else
i.safe_mode="WPA2-PSK"end
i.mac=string.upper(luci.util.exec("cat /sys/class/net/%q/address"%c)or"00:00:00:00:00:00")local l=n.disabled or""local n={["0"]="1",["1"]="0"}i.enable=n[l]or""local n=luci.util.exec("iwconfig %q |grep Channel"%c)i.channel=string.match(n,"%d+")or""local e=e.get_wifi_device_config("2.4G","wifimode")and e.get_wifi_device_config("2.4G","wifimode")[1]or""local n={["9"]="0",["0"]="1",["6"]="2"}i.mode=n[e]or"1"return o.E_NONE,i
end
function get_wifi_5g_config(i)local i={mu_mimo="1",beamforming="1",power="1"}local l=l.cursor()local n
l:foreach("wireless","wifi-iface",function(e)if e.ifname==d then
n=e
return
end
end)if n~=nil then
i={ssid=n.ssid or"",password=n.key or"",hidden=n.hidden or""}else
i={ssid="",password="",hidden=""}end
local l=n.disabled
local n={["0"]="1",["1"]="0"}i.enable=n[l]or""i.channel=e.get_wifi_device_config("5G","channel")and e.get_wifi_device_config("5G","channel")[1]or""i.ap_isolate=e.get_wifi_device_config("5G","noforward")and e.get_wifi_device_config("5G","noforward")[1]or""local n=e.get_wifi_device_config("5G","wifimode")and e.get_wifi_device_config("5G","wifimode")[1]or""local l={["14"]="0",["15"]="1"}i.mode=l[n]or"0"local l={["0"]="0",["1"]="1",["2"]="2"}local n=e.get_wifi_device_config("5G","bw")and e.get_wifi_device_config("5G","bw")[1]or""local e=e.get_wifi_device_config("5G","ht_bsscoexist")and e.get_wifi_device_config("5G","ht_bsscoexist")[1]or""if n=="1"and e=="1"then
i.band_width="4"else
i.band_width=l[n]or""end
local e=0
local n=i.password
if string.find(n,"%l")then
e=e+1
end
if string.find(n,"%u")then
e=e+1
end
if string.find(n,"%d")then
e=e+1
end
if string.find(n,"%W")then
e=3
end
i.safety=tostring(e)return o.E_NONE,i
end
function get_wifi_5g_status(i)require("luci.util")local i={}local n={}local c=l.cursor()local l=e.get_wifi_device_config("5G","type")and e.get_wifi_device_config("5G","type")[1]or""c:foreach("wireless","wifi-iface",function(e)if e.device==l and e.ifname==d then
n=e
return
end
end)if n~=nil then
i.ssid=n.ssid or""else
i.ssid=""end
local l=n.encryption or"none"if string.sub(l,1,4)=="none"then
i.safe_mode="0"elseif string.sub(l,1,4)=="psk+"then
i.safe_mode="WPA-PSK"elseif string.sub(l,1,5)=="psk2+"then
ressult.safe_mode="WPA2-PSK"elseif string.sub(l,1,10)=="psk-mixed+"then
i.safe_mode="WPA-PSK/WPA2-PSK"else
i.safe_mode="WPA2-PSK"end
i.mac=string.upper(luci.util.exec("cat /sys/class/net/%q/address"%d)or"00:00:00:00:00:00")local l=n.disabled or""local n={["0"]="1",["1"]="0"}i.enable=n[l]or""local n=luci.util.exec("iwconfig %q |grep Channel"%d)i.channel=string.match(n,"%d+")or""local n=e.get_wifi_device_config("5G","wifimode")and e.get_wifi_device_config("5G","wifimode")[1]or""local e={["9"]="0",["0"]="1",["6"]="2",["14"]="11a/ac/an混合"}i.mode=e[n]or"1"return o.E_NONE,i
end
