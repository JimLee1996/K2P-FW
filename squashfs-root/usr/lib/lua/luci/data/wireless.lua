local e=require("luci.phicomm.error")local n=require("luci.controller.ds")local c=require("luci.phicomm.validator")local i=n.filter_key.validator
local _=n.filter_key.args
local _=require("luci.data.guide")module("luci.data.wireless",package.seeall)function index()register_secname_cb("wireless","smart_connect","check_smart_connect","apply_smart_connect")register_secname_cb("wireless","wifi_2g_config","check_wifi_2g_config","apply_wifi_2g_config")register_secname_cb("wireless","wifi_5g_config","check_wifi_5g_config","apply_wifi_5g_config")end
function check_smart_connect(l,_,c,l,l,l)n.register_secname_filter(_,c,{enable={[i]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function check_wifi_2g_config(l,_,c,l,l,l)n.register_secname_filter(_,c,{enable={[i]="luci.phicomm.validator.check_bool"},ssid={[i]="luci.data.wireless.check_ssid_2g"},password={[i]="luci.data.wireless.check_pwd_2g"},hidden={[i]="luci.phicomm.validator.check_bool"},mode={[i]="luci.data.wireless.check_mode_2g"},channel={[i]="luci.data.wireless.check_channel_2g"},band_width={[i]="luci.data.wireless.check_band_width_2g"},ap_isolate={[i]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function check_wifi_5g_config(l,_,c,l,l,l)n.register_secname_filter(_,c,{enable={[i]="luci.phicomm.validator.check_bool"},ssid={[i]="luci.data.wireless.check_ssid_5g"},password={[i]="luci.data.wireless.check_pwd_5g"},hidden={[i]="luci.phicomm.validator.check_bool"},mode={[i]="luci.data.wireless.check_mode_5g"},channel={[i]="luci.data.wireless.check_channel_5g"},band_width={[i]="luci.data.wireless.check_band_width_5g"},ap_isolate={[i]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function check_ssid_2g(n,i,i,i)local i=c.check_ssid(n)if i==e.E_SSID_BLANK then
return e.E_WL2GSSIDBLANK
end
if i==e.E_SSID_LEN then
return e.E_WL2GSSIDLEN
end
if i==e.E_SSID_ILLEGAL then
return e.E_WL2GSSIDILLEGAL
end
local i=require("luci.controller.admin.guest")if i then
local c,i=i.get_guest_wifi_conf()local i=i.ssid
if i==n then
return e.E_WL2GSSIDCONFICTWITHGUEST
end
end
return e.E_NONE
end
function check_pwd_2g(i,n,n,n)local i=c.check_wlan_pwd(i)if i==e.E_WIFI_PWD_LEN then
return e.E_WL2GSSIDPWLEN
end
if i==e.E_WIFI_PWD_ILLEGAL then
return e.E_WL2GSSIDPWILLEGAL
end
return e.E_NONE
end
function check_mode_2g(i,n,n,n)if"0"~=i and"1"~=i and"2"~=i then
return e.E_WL2GMODE
end
return e.E_NONE
end
function check_channel_2g(i,n,n,n)if not c.check_num_range(i,0,13)then
return e.E_WL2GCHANNEL
end
return e.E_NONE
end
function check_band_width_2g(i,n,n,n)if"0"~=i and"1"~=i and"2"~=i then
return e.E_WL2GCHWIDTH
end
return e.E_NONE
end
function check_ssid_5g(i,n,n,n)if""==i then
return e.E_WL5GSSIDBLANK
end
if#i>32 then
return e.E_WL5GSSIDLEN
end
local n=c.check_ssid(i)if n~=e.E_NONE then
return e.E_WL5GSSIDILLEGAL
end
local n=require("luci.controller.admin.guest")if n then
local c,n=n.get_guest_wifi_conf()local n=n.ssid
if n==i then
return e.E_WL5GSSIDCONFICTWITHGUEST
end
end
return e.E_NONE
end
function check_pwd_5g(i,n,n,n)if""==i then
return e.E_NONE
end
if#i<8 or#i>64 then
return e.E_WL5GSSIDPWLEN
end
local i=c.check_wlan_pwd(i)if i~=e.E_NONE then
return e.E_WL5GSSIDPWILLEGAL
end
return e.E_NONE
end
function check_mode_5g(i,n,n,n)if"0"~=i and"1"~=i then
return e.E_WL5GMODE
end
return e.E_NONE
end
function check_channel_5g(n,i,i,i)local i={"0","36","40","44","48","52","56","60","64","149","153","157","161","165"}for c,i in ipairs(i)do
if i==n then
return e.E_NONE
end
end
return e.E_WL5GCHANNEL
end
function check_band_width_5g(n,i,i,i)local i={"0","1","2","3","4"}for c,i in ipairs(i)do
if i==n then
return e.E_NONE
end
end
return e.E_WL5GCHWIDTH
end
function apply_smart_connect(i,i,i,i,i,i)return e.E_NONE
end
function apply_wifi_2g_config(n,n,n,n,i,n)local n=require("luci.model.uci").cursor()phicomm_lua=require("phic")local c={ssid="ssid",password="key",hidden="hidden"}local n={channel="channel",ap_isolate="noforward"}local _={["0"]="9",["1"]="0",["2"]="6"}local o={["0"]="1",["1"]="0"}local l={["0"]="0",["1"]="2",["2"]="1"}if i.band_width~=nil then
if i.band_width=="1"then
phicomm_lua.set_wifi_device_config("2.4G","ht_bsscoexist","1")else
phicomm_lua.set_wifi_device_config("2.4G","ht_bsscoexist","0")end
end
if i.band_width~=nil then
phicomm_lua.set_wifi_device_config("2.4G","bw",l[i.band_width])end
if i.enable~=nil then
phicomm_lua.set_wifi_iface_config("2.4G","disabled",o[i.enable])end
if i.mode~=nil then
phicomm_lua.set_wifi_device_config("2.4G","wifimode",_[i.mode])end
if i.password~=nil then
if i.password==""then
phicomm_lua.set_wifi_iface_config("2.4G","encryption","none")else
phicomm_lua.set_wifi_iface_config("2.4G","encryption","psk-mixed+tkip+ccmp")end
phicomm_lua.set_wifi_iface_config("2.4G","key",i.password)end
local _,_
for e,i in pairs(i)do
if c[e]~=nil then
phicomm_lua.set_wifi_iface_config("2.4G",c[e],i)end
if n[e]~=nil then
phicomm_lua.set_wifi_device_config("2.4G",n[e],i)end
end
return e.E_NONE,{wait_time=35}end
function apply_wifi_5g_config(n,n,n,n,i,n)local o=require("luci.model.uci").cursor()phicomm_lua=require("phic")local c={ssid="ssid",password="key",hidden="hidden"}local n={channel="channel",ap_isolate="noforward"}local _={["0"]="14",["1"]="15",}local l={["0"]="1",["1"]="0"}local t={["0"]="0",["2"]="2",}if i.band_width~=nil then
if i.band_width=="1"then
phicomm_lua.set_wifi_device_config("5G","ht_bsscoexist","0")phicomm_lua.set_wifi_device_config("5G","bw","1")elseif i.band_width=="4"then
phicomm_lua.set_wifi_device_config("5G","ht_bsscoexist","1")phicomm_lua.set_wifi_device_config("5G","bw","1")else
phicomm_lua.set_wifi_device_config("5G","bw",t[i.band_width])end
end
if i.enable~=nil then
phicomm_lua.set_wifi_iface_config("5G","disabled",l[i.enable])end
if i.mode~=nil then
phicomm_lua.set_wifi_device_config("5G","wifimode",_[i.mode])end
if i.password~=nil then
if i.password==""then
phicomm_lua.set_wifi_iface_config("5G","encryption","none")else
phicomm_lua.set_wifi_iface_config("5G","encryption","psk-mixed+tkip+ccmp")end
phicomm_lua.set_wifi_iface_config("5G","key",i.password)end
local _,_
for e,i in pairs(i)do
if c[e]~=nil then
phicomm_lua.set_wifi_iface_config("5G",c[e],i)end
if n[e]~=nil then
phicomm_lua.set_wifi_device_config("5G",n[e],i)end
end
o:apply("wireless",false,true)return e.E_NONE,{wait_time=35}end
