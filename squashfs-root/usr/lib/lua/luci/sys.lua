local r=require"io"local u=require"os"local h=require"table"local n=require"nixio"local i=require"nixio.fs"local e={}local t,f,p,m,l,d,g,o,s=tonumber,ipairs,pairs,pcall,type,next,setmetatable,require,select
module"luci.sys"function call(...)return u.execute(...)/256
end
function exec(e)local e=r.popen(e)local n=e:read("*a")e:close()return n
end
function mounts()e.util=o"luci.util"local r={}local i={"fs","blocks","used","available","percent","mountpoint"}local t=e.util.execi("df")if not t then
return
else
t()end
for o in t do
local n={}local e=1
for t in o:gmatch("[^%s]+")do
n[i[e]]=t
e=e+1
end
if n[i[1]]then
if not n[i[2]]then
e=2
o=t()for t in o:gmatch("[^%s]+")do
n[i[e]]=t
e=e+1
end
end
h.insert(r,n)end
end
return r
end
getenv=n.getenv
function hostname(e)if l(e)=="string"and#e>0 then
i.writefile("/proc/sys/kernel/hostname",e)return e
else
return n.uname().nodename
end
end
function httpget(n,i,t)e.util=o"luci.util"if not t then
local e=i and r.popen or e.util.exec
return e("wget -qO- '"..n:gsub("'","").."'")else
return u.execute("wget -qO '%s' '%s'"%{t:gsub("'",""),n:gsub("'","")})end
end
function loadavg()local e=n.sysinfo()return e.loads[1],e.loads[2],e.loads[3]end
function reboot()return u.execute("reboot -f >/dev/null 2>&1")end
function sysinfo()e.util=o"luci.util"local o=i.readfile("/proc/cpuinfo")local r=i.readfile("/proc/meminfo")local l=t(r:match("MemTotal:%s*(%d+)"))local a=t(r:match("\nCached:%s*(%d+)"))local d=t(r:match("MemFree:%s*(%d+)"))local r=t(r:match("Buffers:%s*(%d+)"))local c=t(o:match("[Bb]ogo[Mm][Ii][Pp][Ss].-: ([^\n]+)"))or 0
local t=o:match("system type\t+: ([^\n]+)")or
o:match("Processor\t+: ([^\n]+)")or
o:match("model name\t+: ([^\n]+)")local e=e.util.pcdata(i.readfile("/tmp/sysinfo/model"))or
o:match("machine\t+: ([^\n]+)")or
o:match("Hardware\t+: ([^\n]+)")or
e.util.pcdata(i.readfile("/proc/diag/model"))or
n.uname().machine or
t
return t,e,l,a,r,d,c
end
function syslog()e.util=o"luci.util"return e.util.exec("logread")end
function dmesg()e.util=o"luci.util"return e.util.exec("dmesg")end
function uniqueid(e)local e=i.readfile("/dev/urandom",e)return e and n.bin.hexlify(e)end
function uptime()return n.sysinfo().uptime
end
net={}function net.arptable(t)local n,o,o,e
if i.access("/proc/net/arp")then
for i in r.lines("/proc/net/arp")do
local e={},e
for n in i:gmatch("%S+")do
e[#e+1]=n
end
if e[1]~="IP"then
local e={["IP address"]=e[1],["HW type"]=e[2],["Flags"]=e[3],["HW address"]=e[4],["Mask"]=e[5],["Device"]=e[6]}if t then
t(e)else
n=n or{}n[#n+1]=e
end
end
end
end
return n
end
local function c(a,m)e.util=o"luci.util"local t,t,t,l,d,u
local t=o"luci.model.uci"local h=t.cursor()local o={}local t={}local function c(e,...)local e=s(e,...)if e then
if not t[e]then t[e]={}end
t[e][1]=s(1,...)or t[e][1]t[e][2]=s(2,...)or t[e][2]t[e][3]=s(3,...)or t[e][3]t[e][4]=s(4,...)or t[e][4]end
end
if i.access("/proc/net/arp")then
for e in r.lines("/proc/net/arp")do
d,l=e:match("^([%d%.]+)%s+%S+%s+%S+%s+([a-fA-F0-9:]+)%s+")if d and l then
c(a,l:upper(),d,nil,nil)end
end
end
if i.access("/etc/ethers")then
for e in r.lines("/etc/ethers")do
l,d=e:match("^([a-f0-9]%S+) (%S+)")if l and d then
c(a,l:upper(),d,nil,nil)end
end
end
if i.access("/var/dhcp.leases")then
for e in r.lines("/var/dhcp.leases")do
l,d,u=e:match("^%d+ (%S+) (%S+) (%S+)")if l and d then
c(a,l:upper(),d,nil,u~="*"and u)end
end
end
h:foreach("dhcp","host",function(n)for e in e.util.imatch(n.mac)do
c(a,e:upper(),n.ip,nil,n.name)end
end)for n,e in f(n.getifaddrs())do
if e.name~="lo"then
o[e.name]=o[e.name]or{}if e.family=="packet"and e.addr and#e.addr==17 then
o[e.name][1]=e.addr:upper()elseif e.family=="inet"then
o[e.name][2]=e.addr
elseif e.family=="inet6"then
o[e.name][3]=e.addr
end
end
end
for n,e in p(o)do
if e[a]and(e[2]or e[3])then
c(a,e[1],e[2],e[3],e[4])end
end
for n,e in e.util.kspairs(t)do
m(e[1],e[2],e[3],e[4])end
end
function net.mac_hints(r)if r then
c(1,function(i,t,o,e)e=e or n.getnameinfo(t or o,nil,100)or t
if e and e~=i then
r(i,e or n.getnameinfo(t or o,nil,100)or t)end
end)else
local i={}c(1,function(r,t,o,e)e=e or n.getnameinfo(t or o,nil,100)or t
if e and e~=r then
i[#i+1]={r,e or n.getnameinfo(t or o,nil,100)or t}end
end)return i
end
end
function net.ipv4_hints(i)if i then
c(2,function(o,t,r,e)e=e or n.getnameinfo(t,nil,100)or o
if e and e~=t then
i(t,e)end
end)else
local i={}c(2,function(o,t,r,e)e=e or n.getnameinfo(t,nil,100)or o
if e and e~=t then
i[#i+1]={t,e}end
end)return i
end
end
function net.ipv6_hints(i)if i then
c(3,function(o,r,t,e)e=e or n.getnameinfo(t,nil,100)or o
if e and e~=t then
i(t,e)end
end)else
local t={}c(3,function(o,r,i,e)e=e or n.getnameinfo(i,nil,100)or o
if e and e~=i then
t[#t+1]={i,e}end
end)return t
end
end
function net.conntrack(t)local n={}if i.access("/proc/net/nf_conntrack","r")then
for e in r.lines("/proc/net/nf_conntrack")do
e=e:match"^(.-( [^ =]+=).-)%2"local e,i=_parse_mixed_record(e," +")if i[6]~="TIME_WAIT"then
e.layer3=i[1]e.layer4=i[3]for n=1,#e do
e[n]=nil
end
if t then
t(e)else
n[#n+1]=e
end
end
end
elseif i.access("/proc/net/ip_conntrack","r")then
for e in r.lines("/proc/net/ip_conntrack")do
e=e:match"^(.-( [^ =]+=).-)%2"local e,i=_parse_mixed_record(e," +")if i[4]~="TIME_WAIT"then
e.layer3="ipv4"e.layer4=i[1]for n=1,#e do
e[n]=nil
end
if t then
t(e)else
n[#n+1]=e
end
end
end
else
return nil
end
return n
end
function net.defaultroute()local e
net.routes(function(n)if n.dest:prefix()==0 and(not e or e.metric>n.metric)then
e=n
end
end)return e
end
function net.defaultroute6()e.ip=o"luci.ip"local n
net.routes6(function(e)if e.dest:prefix()==0 and e.device~="lo"and(not n or n.metric>e.metric)then
n=e
end
end)if not n then
local t=e.ip.IPv6("2000::/3")net.routes6(function(e)if e.dest:equal(t)and(not n or n.metric>e.metric)then
n=e
end
end)end
return n
end
function net.devices()local e={}for t,n in f(n.getifaddrs())do
if n.family=="packet"then
e[#e+1]=n.name
end
end
return e
end
function net.deviceinfo()local t={}for e,n in f(n.getifaddrs())do
if n.family=="packet"then
local e=n.data
e[1]=e.rx_bytes
e[2]=e.rx_packets
e[3]=e.rx_errors
e[4]=e.rx_dropped
e[5]=0
e[6]=0
e[7]=0
e[8]=e.multicast
e[9]=e.tx_bytes
e[10]=e.tx_packets
e[11]=e.tx_errors
e[12]=e.tx_dropped
e[13]=0
e[14]=e.collisions
e[15]=0
e[16]=0
t[n.name]=e
end
end
return t
end
function net.ip4mac(t)local n=nil
net.arptable(function(e)if e["IP address"]==t then
n=e["HW address"]end
end)return n
end
function net.routes(l)e.ip=o"luci.ip"local i={}for n in r.lines("/proc/net/route")do
local d,o,r,p,u,s,f,n,c,h,a=n:match("([^%s]+)\t([A-F0-9]+)\t([A-F0-9]+)\t([A-F0-9]+)\t".."(%d+)\t(%d+)\t(%d+)\t([A-F0-9]+)\t(%d+)\t(%d+)\t(%d+)")if d then
r=e.ip.Hex(r,32,e.ip.FAMILY_INET4)n=e.ip.Hex(n,32,e.ip.FAMILY_INET4)o=e.ip.Hex(o,n:prefix(n),e.ip.FAMILY_INET4)local e={dest=o,gateway=r,metric=t(f),refcount=t(u),usecount=t(s),mtu=t(c),window=t(window),irtt=t(a),flags=t(p,16),device=d}if l then
l(e)else
i[#i+1]=e
end
end
end
return i
end
function net.routes6(f)e.ip=o"luci.ip"if i.access("/proc/net/ipv6_route","r")then
local l={}for n in r.lines("/proc/net/ipv6_route")do
local o,p,n,u,i,r,s,c,a,d=n:match("([a-f0-9]+) ([a-f0-9]+) ".."([a-f0-9]+) ([a-f0-9]+) ".."([a-f0-9]+) ([a-f0-9]+) ".."([a-f0-9]+) ([a-f0-9]+) ".."([a-f0-9]+) +([^%s]+)")if o and p and
n and u and
i and r and
s and c and
a and d
then
n=e.ip.Hex(n,t(u,16),e.ip.FAMILY_INET6,false)o=e.ip.Hex(o,t(p,16),e.ip.FAMILY_INET6,false)i=e.ip.Hex(i,128,e.ip.FAMILY_INET6,false)local e={source=n,dest=o,nexthop=i,metric=t(r,16),refcount=t(s,16),usecount=t(c,16),flags=t(a,16),device=d,metric_raw=r}if f then
f(e)else
l[#l+1]=e
end
end
end
return l
end
end
function net.pingtest(e)return u.execute("ping -c1 '"..e:gsub("'",'').."' >/dev/null 2>&1")end
process={}function process.info(t)local e={uid=n.getuid(),gid=n.getgid()}return not t and e or e[t]end
function process.list()e.util=o"luci.util"local n={}local i
local e=e.util.execi("/bin/busybox top -bn1")if not e then
return
end
for e in e do
local i,o,l,r,d,c,a,s=e:match("^ *(%d+) +(%d+) +(%S.-%S) +([RSDZTW][W ][<N ]) +(%d+) +(%d+%%) +(%d+%%) +(.+)")local e=t(i)if e then
n[e]={['PID']=i,['PPID']=o,['USER']=l,['STAT']=r,['VSZ']=d,['%MEM']=c,['%CPU']=a,['COMMAND']=s}end
end
return n
end
function process.setgroup(e)return n.setgid(e)end
function process.setuser(e)return n.setuid(e)end
process.signal=n.kill
user={}user.getuser=n.getpw
function user.getpasswd(e)local n=n.getsp and n.getsp(e)or n.getpw(e)local e=n and(n.pwdp or n.passwd)if not e or#e<1 or e=="!"or e=="x"then
return nil,n
else
return e,n
end
end
function user.checkpasswd(e,i)local e,t=user.getpasswd(e)if t then
return(e==nil or n.crypt(i,e)==e)end
return false
end
function user.setpasswd(n,e)if e then
e=e:gsub("'",[['"'"']])end
if n then
n=n:gsub("'",[['"'"']])end
return u.execute("(echo '"..e.."'; sleep 1; echo '"..e.."') | ".."passwd '"..n.."' >/dev/null 2>&1")end
wifi={}function wifi.getiwinfo(e)local d,l=m(o,"iwinfo")local n=o"luci.model.uci"if e then
local o=0
local i=n.cursor_state()local r,n=e:match("^(%w+)%.network(%d+)")if r and n then
e=r
n=t(n)i:foreach("wireless","wifi-iface",function(t)if t.device==r then
o=o+1
if o==n then
e=t.ifname or t.device
return false
end
end
end)elseif i:get("wireless",e)=="wifi-device"then
i:foreach("wireless","wifi-iface",function(n)if n.device==e and n.ifname then
e=n.ifname
return false
end
end)end
local n=d and l.type(e)local t=n and l[n]or{}return g({},{__index=function(i,n)if n=="ifname"then
return e
elseif t[n]then
return t[n](e)end
end})end
end
init={}init.dir="/etc/init.d/"function init.names()local e={}for n in i.glob(init.dir.."*")do
e[#e+1]=i.basename(n)end
return e
end
function init.index(e)if i.access(init.dir..e)then
return call("env -i sh -c 'source %s%s enabled; exit ${START:-255}' >/dev/null"%{init.dir,e})end
end
local function n(n,e)if i.access(init.dir..e)then
return call("env -i %s%s %s >/dev/null"%{init.dir,e,n})end
end
function init.enabled(e)return(n("enabled",e)==0)end
function init.enable(e)return(n("enable",e)==1)end
function init.disable(e)return(n("disable",e)==0)end
function init.start(e)return(n("start",e)==0)end
function init.stop(e)return(n("stop",e)==0)end
function _parse_mixed_record(r,n)e.util=o"luci.util"n=n or"  "local i={}local t={}for r,o in p(e.util.split(e.util.trim(r),"\n"))do
for n,e in p(e.util.split(e.util.trim(o),n,nil,true))do
local e,n,o=e:match('([^%s][^:=]*) *([:=]*) *"*([^\n"]*)"*')if e then
if n==""then
h.insert(t,e)else
i[e]=o
end
end
end
end
return i,t
end
