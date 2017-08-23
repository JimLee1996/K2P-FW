local t,e=string,type
local n=require("luci.phicomm.error")local u=require("luci.phicomm.util")local o=require("luci.phicomm.lib.bit").bit
local r=print
module("luci.phicomm.validator",package.seeall)function check_bool(e)if"0"~=e and"1"~=e and 1~=e and 0~=e then
return n.E_INVBOOL
end
return n.E_NONE
end
function check_passwd(e)if nil==e then
return n.E_PWDBLANK
end
if#e<5 or#e>63 then
return n.E_PWDLEN
end
local r="^[%a%d%p]+$"if not t.match(e,r)then
return n.E_PWDILLEGAL
end
return n.E_NONE
end
function check_wlan_pwd(r)if e(r)~="string"then
return n.E_WIFI_PWD_ILLEGAL
end
if r==""then
return n.E_NONE
end
local e=#r
if e<=63 and e>=8 then
local i=127
for e=1,e do
local e=t.byte(r,e,e)if e>i then
return n.E_WIFI_PWD_ILLEGAL
end
end
return n.E_NONE
else
return n.E_WIFI_PWD_LEN
end
end
function check_ssid(t)if e(t)~="string"then
return n.E_SSID_ILLEGAL
end
if t==""then
return n.E_SSID_BLANK
end
if#t<1 or#t>32 then
return n.E_SSID_LEN
end
return n.E_NONE
end
function valid_ip_format(r)if e(r)~="string"then
return n.E_INVIP
end
local e=t.match(r,"^%d+%.%d+%.%d+%.%d+$")if not e then
return n.E_INVIPFMT
else
return n.E_NONE
end
end
local l=1
local d=2
local r=3
function valid_ip_addr(c,e)local i=0
for e in t.gmatch(c,"%d+")do
if t.match(e,"^0%d+")then
return n.E_INVIP
end
i=tonumber(e)if 255<i then
return n.E_INVIP
end
end
local t=tonumber(t.match(c,"%d+"))if 0==t or 224<t then
return n.E_INVNET
end
if nil==e or l~=e or r~=e then
if 224==t then
return n.E_INVMACGROUP
end
end
if nil==e or d~=e or r~=e then
if 127==t then
return n.E_INVLOOPIP
end
end
return n.E_NONE
end
function check_ip(t,r)if e(t)~="string"or""==t then
return n.E_INVIP
end
local e=n.E_NONE
e=valid_ip_format(t)if(n.E_NONE~=e)then
return e
end
e=valid_ip_addr(t,r)if(n.E_NONE~=e)then
return e
end
return e
end
function check_mac(r)if e(r)~="string"then
return n.E_INVMACFMT
end
local e="^%x%x:%x%x:%x%x:%x%x:%x%x:%x%x$"local e=t.match(r,e)if not e then
return n.E_INVMACFMT
end
local e=t.lower(r)if"00:00:00:00:00:00"==e then
return n.E_INVMACZERO
end
if"ff:ff:ff:ff:ff:ff"==e then
return n.E_INVMACBROAD
end
if"01"==t.sub(r,1,2)then
return n.E_INVMACGROUP
end
return n.E_NONE
end
function trans_ip(e)local n=0
for e in t.gmatch(e,"%d+")do
n=n*256+tonumber(e)end
return n
end
function check_mask(r)if e(r)~="string"or""==r then
return n.E_INVMASK
end
if n.E_NONE~=valid_ip_format(r)then
return n.E_INVMASK
end
if t.match(r,"00")then
return n.E_INVMASK
end
local e=4294967295
local t=e-trans_ip(r)+1
local e=0
for e=1,31 do
if t==math.pow(2,e)then
return n.E_NONE
end
end
return n.E_INVMASK
end
function check_num(n)if e(n)~="string"and e(n)~="number"or""==n then
return false
end
if nil~=t.match(n,"%D")then
return false
end
return true
end
function check_num_range(n,e,t)if not check_num(n)or not check_num(t)or not check_num(e)then
return false
end
local n=tonumber(n)local e,t=tonumber(t),tonumber(e)if nil==n or n<t or n>e then
return false
end
return true
end
function check_mtu(r,t,e)if not check_num(r)then
return n.EINVMTU
end
if nil==t then t=1500 end
if nil==e then e=576 end
if not check_num_range(r,t,e)then
return n.EINVMTU
end
return n.E_NONE
end
function check_ip_nethost(i,e)local t=require("luci.phicomm.lib.bit").bit
local r=t:bit_and(i,e)if 0==r or e==r then
return n.EINVNETID
end
local e=t:bit_not(e)local t=t:bit_and(i,e)if 0==t or e==t then
return n.EINVHOSTID
end
return n.E_NONE
end
function get_ip_class(n)local n=tonumber(t.match(n,"%d+"))if n<=127 then return"A"end
if n<=192 then return"B"end
if n<=223 then return"C"end
if n<=239 then return"D"end
return"E"end
function check_ip_class(e,i)local r=require("luci.phicomm.lib.bit").bit
local t=get_ip_class(e)local e=trans_ip(e)local i=trans_ip(i)if"A"==t then
e=r:bit_and(4278190080,e)elseif"B"==t then
e=r:bit_and(4294901760,e)elseif"C"==t then
e=r:bit_and(4294967040,e)end
if i<e then
return n.E_INVIPMASKPAIR
end
return n.E_NONE
end
function check_ip_mask(r,t)if e(r)~="string"or e(t)~="string"then
return n.E_INVIPMASKPAIR
end
local e=n.E_NONE
local i=trans_ip(r)local c=trans_ip(t)e=check_ip_nethost(i,c)if n.E_NONE~=e then
return e
end
e=check_ip_class(r,t)if n.E_NONE~=e then
return e
end
return n.E_NONE
end
function check_same_network(t,r,n)t="number"==e(t)and t or trans_ip(t)r="number"==e(r)and r or trans_ip(r)n="number"==e(n)and n or trans_ip(n)return o:bit_and(t,n)==o:bit_and(r,n)end
function check_domain(n)if e(n)~="string"or#n>255 then
return false
end
local e="^[%w%.%-]+$"if not t.match(n,e)then
return false
end
local n=u.split_string(n,".")for e,n in pairs(n)do
if#n==0 or#n>=64 then
return false
end
end
return true
end
