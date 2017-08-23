local e=require("luci.phicomm.error")local c=require("luci.controller.ds")local i=require("luci.phicomm.validator")local n=c.filter_key.validator
local l=c.filter_key.args
module("luci.data.wifi_extend",package.seeall)function index()register_secname_cb("wisp","config","check_wisp_config","apply_wisp_config")end
function check_wisp_config(_,l,i,_,_,_)c.register_secname_filter(l,i,{enable={[n]="luci.phicomm.validator.check_bool"},band={[n]="luci.data.wifi_extend.check_band"},ssid={[n]="luci.data.wifi_extend.check_ssid_wisp"},safe_mode={[n]="luci.data.wifi_extend.check_safe_mode"},encryption={[n]="luci.data.wifi_extend.check_encryption"},password={[n]="luci.data.wifi_extend.check_pwd_wisp"},bssid={[n]="luci.data.wifi_extend.check_bssid"}})return e.E_NONE
end
function check_band(n,c,c,c)local i=i.check_bool(n)if""==n then
return e.E_NONE
end
if i~=e.E_NONE then
return e.E_INVBOOL
end
return e.E_NONE
end
function check_ssid_wisp(n,c,c,c)local n=i.check_ssid(n)if n==e.E_SSID_BLANK then
return e.E_WISPSSIDBLANK
end
if n==e.E_SSID_LEN then
return e.E_WISPSSIDLEN
end
if n==e.E_SSID_ILLEGAL then
return e.E_WISPSSIDILLEGAL
end
return e.E_NONE
end
function check_safe_mode(i,n,n,n)local n={"OPEN","WPA-PSK","WPA2-PSK","WPAWPA2-PSK","WPAENT"}local c
for c,n in pairs(n)do
if n==i then
return e.E_NONE
end
end
return e.E_WISPSECAUTH
end
function check_encryption(n,i,i,i)local i={"NONE","TKIP","AES","TKIPAES"}local c
for c,i in pairs(i)do
if i==n then
return e.E_NONE
end
end
return e.E_WISPPSKPWENCRYPT
end
function check_pwd_wisp(n,c,l,l)if c.safe_mode~="OPEN"then
if""==n then
return e.E_WISPPSKPWBLANK
end
local n=i.check_wlan_pwd(n)if n==e.E_WIFI_PWD_LEN then
return e.E_WISPPSKPWLEN
end
if n==e.E_WIFI_PWD_ILLEGAL then
return e.E_WISPPSKPWILLEGAL
end
return e.E_NONE
end
return e.E_NONE
end
function check_bssid(n,c,c,c)local i=i.check_mac(n)if""==n then
return e.E_NONE
end
if i~=e.E_NONE then
return e.E_DEVMNG_EMAC
end
return e.E_NONE
end
function apply_wisp_config(n,n,n,i,n,n)local c=require("apcli")local n=uci.cursor()local n=i.enable
local l="0"local l="0"if n=="0"then
c.config_normal()else
local t=i.ssid
local r=i.bssid
local _="0"local e=i.safe_mode
if e=="WPA2-PSK"or e=="WPAWPA2-PSK"then
e="WPA2PSK"elseif e=="WPA-PSK"then
e="WPAPSK"elseif e=="WPAENT"then
e="WPA"else
e="OPEN"end
local n=i.encryption
if n=="TKIPAES"or n=="AES"then
encrpt="AES"elseif n=="TKIP"then
n="TKIP"else
n="NONE"end
local i=i.password or""l=c.config_apcli(t,r,e,n,i,_)end
if l.result==-89 then
return e.E_WISPNOTFOUND
else
os.execute("(sleep 1; reboot) &")return e.E_NONE,{wait_time=60}end
end
