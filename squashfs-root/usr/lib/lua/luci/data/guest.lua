local e=require("luci.phicomm.error")local c=require("luci.phicomm.validator")local i=require("luci.controller.ds")local n=i.filter_key.validator
local t=i.filter_key.args
module("luci.data.guest",package.seeall)function index()register_secname_cb("wireless","guest_wifi","check_guest","apply_guest_config")end
function check_guest(l,t,c,l,l,l)i.register_secname_filter(t,c,{enable={[n]="luci.phicomm.validator.check_bool"},ssid={[n]="luci.data.guest.check_guest_ssid"},password={[n]="luci.data.guest.check_guest_pwd"}})return e.E_NONE
end
function check_guest_ssid(n,i,i,i)local i=c.check_ssid(n)if i==e.E_SSID_BLANK then
return e.E_WLVISSSIDBLANK
end
if i==e.E_SSID_LEN then
return e.E_WLVISSSIDLEN
end
if i==e.E_SSID_ILLEGAL then
return e.E_WLVISSSIDILLEGAL
end
local i=require("luci.controller.admin.wireless")if i then
local c,i=i.get_wifi_2g_config()local i=i.ssid
if i==n then
return e.E_WLVISSSIDCONFLICT2G
end
end
if i then
local c,i=i.get_wifi_5g_config()local i=i.ssid
if i==n then
return e.E_WLVISSSIDCONFLICT5G
end
end
return e.E_NONE
end
function check_guest_pwd(i,n,n,n)local i=c.check_wlan_pwd(i)if i==e.E_WIFI_PWD_LEN then
return e.E_WLVISSSIDPWLEN
end
if i==e.E_WIFI_PWD_ILLEGAL then
return e.E_WLVISSSIDPWILLEGAL
end
return e.E_NONE
end
function apply_guest_config(n,n,n,n,i,n)local c=require("luci.model.uci").cursor()local n=require("phic")local t={["0"]="1",["1"]="0"}if i.enable~=nil then
n.set_wifi_iface_config("Guest","disabled",t[i.enable])end
if i.password~=nil then
if i.password==""then
n.set_wifi_iface_config("Guest","encryption","none")else
n.set_wifi_iface_config("Guest","encryption","psk-mixed+tkip+ccmp")end
n.set_wifi_iface_config("Guest","key",i.password)end
if i.ssid~=nil then
n.set_wifi_iface_config("Guest","ssid",i.ssid)end
c:apply("wireless",false,true)return e.E_NONE,{wait_time=28}end
