local r=require("luci.phicomm.error")module("luci.controller.admin.network",package.seeall)function index()entry({"pc","networkSet.htm"},template("pc/networkSet")).leaf=true
entry({"h5","networkSet.htm"},template("h5/networkSet")).leaf=true
register_keyword_data("network","wan","get_wan_config")register_keyword_data("network","static","get_static_config")register_keyword_data("network","dhcp","get_dhcp_config")register_keyword_data("network","pppoe","get_pppoe_config")register_keyword_data("network","wan_status","get_wan_status")register_keyword_data("network","wan_detection","get_wan_detection")end
function get_wan_config(e)local e=require("luci.model.uci")local e=e.cursor()local n={protocol=e:get("network","wan","proto"),mac=e:get("network","wan","mac_addr")or"",source_mac=e:get("network","wan","macaddr")or""}local e=e:get("network","wan","macoperate")local t={["1"]="0",["2"]="1"}n.clone_mode=t[e]or""return r.E_NONE,n
end
function get_static_config(e)local e=require("luci.model.uci")local e=e.cursor()local n={ip=e:get("network","wan","ipaddr"),netmask=e:get("network","wan","netmask"),gateway=e:get("network","wan","gateway"),dns_mode="1",dns_pri=e:get("network","wan","static_dns1")or"",dns_sec=e:get("network","wan","static_dns2")or""}local t=e:get("network","wan","ignore_mtu_change_pppoe")if t=="1"then
n.mtu="1500"else
n.mtu=e:get("network","wan","mtu")end
return r.E_NONE,n
end
function get_dhcp_config(e)local e=require("luci.model.uci")local e=e.cursor()local n={dns_pri=e:get("network","wan","dns1")or"",dns_sec=e:get("network","wan","dns2")or"",dns_mode=e:get("network","wan","dhcp_dns_mode")}local t=e:get("network","wan","ignore_mtu_change_pppoe")if t=="1"then
n.mtu="1500"else
n.mtu=e:get("network","wan","mtu")end
return r.E_NONE,n
end
function get_pppoe_config(e)local e=require("luci.model.uci")local e=e.cursor()local n={username=e:get("network","wan","username")or"",password=e:get("network","wan","password")or"",dial_mode=e:get("network","wan","DiaMode")or"",server=e:get("network","wan","service")or"",dns_pri=e:get("network","wan","pppoedns1")or"",dns_sec=e:get("network","wan","pppoedns2")or"",dns_mode=e:get("network","wan","pppoe_dns_mode")}local t=e:get("network","wan","mtu")local e=e:get("network","wan","ignore_mtu_change_pppoe")if e=="1"then
n.mtu=tostring(tonumber(t)-8)else
n.mtu="1480"end
return r.E_NONE,n
end
function pingalive(n)local t=1
local a=64
local e={wan_loss=0,wan_bad=0}if not n or""==n then
return e
end
local t=io.popen("ping -c %s -s %s -W 1 -w 2 %q 2>&1"%{t,a,n})if t then
while true do
local n=t:read("*l")if not n then break end
local a,t=string.find(tostring(n),"100%% packet loss")local a,n=string.find(tostring(n),"bad address")if t then
e.wan_loss=1
break
end
if n then
e.wan_bad=1
break
end
end
end
t:close()return e
end
function get_wan_status_code(e)require("ubus")local o=ubus.connect()local e=require("luci.model.uci")local t=e.cursor()local e=""local n=""n=o:call("rth.inet","get_inet_link",{})if n["inet_link"]=="up"then
e="0"else
n=o:call("rth.inet","get_wan_link",{})if n["wan_link"]=="down"then
e="1"else
n=o:call("network.interface.wan","status",{})local a=""a=t:get("network","wan","proto")local r=""local l=n["ipv4-address"]r=(l and#l>0 and l[1].address)or""if a=="dhcp"or a=="pppoe"then
if r==""or r=="0.0.0.0"then
e="2"if a=="pppoe"then
n=o:call("rth.inet","get_pppd_status",{})e=n["pppd_status"]if e=="0"then
e="9"end
else
e="7"end
else
local o=""local r,r
for n,e in ipairs(n["route"]or{})do
if e.target=="0.0.0.0"and e.mask==0 then
o=e.nexthop or""end
end
local o=pingalive(o)if o.wan_loss==1 or o.wan_bad==1 then
e="3"else
local r=""local o=""if t:get("network","wan","peerdns")=="0"then
if a=="dhcp"then
r=t:get("network","wan","dns1")or""o=t:get("network","wan","dns2")or""else
r=t:get("network","wan","pppoedns1")or""o=t:get("network","wan","pppoedns2")or""end
else
local e={}local t,t
for t,n in ipairs(n["dns-server"]or{})do
if not n:match(":")then
e[#e+1]=n
end
end
r=e[1]or""o=e[2]or""end
local n=t:get("network","wan","peerdns")if n==nil or n=="1"then
if(#r==0 or r=="")and(#o==0 or o=="")then
e="4"else
e="5"end
else
e="6"end
end
end
end
end
end
return e
end
function get_wisp_connect(t)local n,e=pcall(require,"iwinfo")local n=0
levle=e.get_wisp_connect(t)for t,e in ipairs(levle or{})do
if t or e then
n=e
end
end
return n
end
function get_wan_status(e)require("ubus")local c=ubus.connect()local e=require("luci.model.uci")local a=e.cursor()local e=c:call("rth.inet","get_wan_link",{})local w=e["wan_link"]local e={protocol=a:get("network","wan","proto")}local n=require("phic")local t=n.default_2g_wisp_ifname()[1]local n=n.default_5g_wisp_ifname()[1]local s=get_wisp_connect(t)local d=get_wisp_connect(n)wan_ifname=a:get("network","wan","ifname")require("luci.util")if wan_ifname==t then
local n=luci.util.exec("ifconfig %q | grep HWaddr"%t)e.mac=string.upper(string.match(n,"%w+:%w+:%w+:%w+:%w+:%w+")or"00:00:00:00:00:00")elseif wan_ifname==n then
local n=luci.util.exec("ifconfig %q | grep HWaddr"%n)e.mac=string.upper(string.match(n,"%w+:%w+:%w+:%w+:%w+:%w+")or"00:00:00:00:00:00")else
if a:get("network","wan","ignore")=="1"then
e.mac=string.upper(a:get("network","wan","macaddr")or"00:00:00:00:00:00")else
e.mac=string.upper(a:get("network","wan","mac_addr")or"00:00:00:00:00:00")end
end
local o=c:call("network.interface.wan","status",{})local l=o["ipv4-address"]local i=(l and#l>0 and l[1].address)or"0.0.0.0"if i and((wan_ifname==t or wan_ifname==n)or w=="up")then
if wan_ifname==t or wan_ifname==n then
if wan_ifname==t and s==0 then
e.ip="0.0.0.0"end
if wan_ifname==n and d==0 then
e.ip="0.0.0.0"end
end
e.ip=i
else
e.ip="0.0.0.0"end
local i=require"luci.ip"local l=(l and#l>0 and
i.IPv4("0.0.0.0/%d"%l[1].mask):mask():string())or"0.0.0.0"if l and((wan_ifname==t or wan_ifname==n)or w=="up")then
if wan_ifname==t or wan_ifname==n then
if wan_ifname==t and s==0 then
e.netmask="0.0.0.0"end
if wan_ifname==n and d==0 then
e.netmask="0.0.0.0"end
end
e.netmask=l
else
e.netmask="0.0.0.0"end
local l="0.0.0.0"local i,i
for n,e in ipairs(o["route"]or{})do
if e.target=="0.0.0.0"and e.mask==0 then
l=e.nexthop or"0.0.0.0"else
l="0.0.0.0"end
end
if l and((wan_ifname==t or wan_ifname==n)or w=="up")then
if wan_ifname==t or wan_ifname==n then
if wan_ifname==t and s==0 then
e.gateway="0.0.0.0"end
if wan_ifname==n and d==0 then
e.gateway="0.0.0.0"end
end
e.gateway=l
else
e.gateway="0.0.0.0"end
local l="0.0.0.0"local i="0.0.0.0"if e.protocol=="static"then
l=a:get("network","wan","static_dns1")or"0.0.0.0"i=a:get("network","wan","static_dns2")or"0.0.0.0"else
if a:get("network","wan","peerdns")=="0"then
if e.protocol=="dhcp"then
l=a:get("network","wan","dns1")or"0.0.0.0"i=a:get("network","wan","dns2")or"0.0.0.0"else
l=a:get("network","wan","pppoedns1")or"0.0.0.0"i=a:get("network","wan","pppoedns2")or"0.0.0.0"end
else
local e={}local n,n
for t,n in ipairs(o["dns-server"]or{})do
if not n:match(":")then
e[#e+1]=n
end
end
l=e[1]or"0.0.0.0"i=e[2]or"0.0.0.0"end
end
if l and i and((wan_ifname==t or wan_ifname==n)or w=="up")then
if wan_ifname==t or wan_ifname==n then
if wan_ifname==t and s==0 then
e.dns_pri="0.0.0.0"e.dns_sec="0.0.0.0"end
if wan_ifname==n and d==0 then
e.dns_pri="0.0.0.0"e.dns_sec="0.0.0.0"end
end
e.dns_pri=l
e.dns_sec=i
else
e.dns_pri="0.0.0.0"e.dns_sec="0.0.0.0"end
o=c:call("rth.inet","get_wan_speed",{})e.upload_speed=tostring(o["tx_rate"])or"0"e.download_speed=tostring(o["rx_rate"])or"0"o=c:call("rth.inet","get_inet_link",{})if o["inet_link"]=="up"then
e.internet_status="1"else
e.internet_status="0"end
e.status_code=get_wan_status_code()return r.E_NONE,e
end
function __get_wan_detection(n)local a=0
local e={running_status="0",}e.status_code=get_wan_status_code()if e.status_code~="1"then
if n.action=="start"then
e.running_status="1"e.protocol="static"os.execute("autodetect &")elseif n.action=="get"then
local n=io.open("/tmp/autodetect","r")if n~=nil then
local t=n:read("*a");local n=string.sub(t,-1,-1)local t=string.sub(t,1,1)if n=="1"then
e.running_status="1"e.protocol="static"elseif n=="2"then
a=tonumber(t)e.running_status="2"local n={"static","dhcp","pppoe","static"}e.protocol=n[a+1]else
e.running_status="0"e.protocol="static"end
else
e.running_status="0"e.protocol="static"end
else
e.running_status="0"e.protocol="static"end
else
e.running_status="2"e.protocol="static"end
return r.E_NONE,e
end
function get_wan_detection(c)local d=require("luci.http")local s=require("luci.fs")local o=require("nixio")local e=10
local l=0
local n={}local a="/tmp/autodetect"local i={"static","dhcp","pppoe","static"}local t
if not d.getenv("PHIAPP_REQUEST")then
return __get_wan_detection(c)end
os.execute("rm -rf "..a)os.execute("autodetect > /dev/null 2>1 &")while e>0 do
o.nanosleep(1,0)e=e-1
if s.access(a)then
break
end
end
n.status_code=get_wan_status_code()n.running_status="2"n.protocol="static"while e>0 do
o.nanosleep(1,0)e=e-1
t=io.open(a,"r")if t then
local e=t:read("*a");local a=string.sub(e,-1,-1)local e=string.sub(e,1,1)if a=="2"and e then
l=tonumber(e)or 0
n.protocol=i[l+1]or"static"t:close()break
end
t:close()end
end
return r.E_NONE,n
end
