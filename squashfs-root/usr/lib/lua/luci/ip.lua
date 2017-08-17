module("luci.ip",package.seeall)require"nixio"local n=nixio.bit
local h=require"luci.util"LITTLE_ENDIAN=not h.bigendian()BIG_ENDIAN=not LITTLE_ENDIAN
FAMILY_INET4=4
FAMILY_INET6=6
local function i(n)return setmetatable(n,{__index=luci.ip.cidr,__add=luci.ip.cidr.add,__sub=luci.ip.cidr.sub,__lt=luci.ip.cidr.lower,__eq=luci.ip.cidr.equal,__le=function(...)return luci.ip.cidr.equal(...)or luci.ip.cidr.lower(...)end})end
local function s(e,t)local r
if type(e)=="number"then
r={n.rshift(e,16),n.band(e,65535)}elseif type(e)=="string"then
if e:find(":")then e=IPv6(e)else e=IPv4(e)end
if e then
assert(e[1]==t,"Can't mix IPv4 and IPv6 addresses")r={unpack(e[2])}end
elseif type(e)=="table"and type(e[2])=="table"then
assert(e[1]==t,"Can't mix IPv4 and IPv6 addresses")r={unpack(e[2])}elseif type(e)=="table"then
r={unpack(e)}end
assert(r,"Invalid operand")return r
end
local function u(e)return n.lshift(n.rshift(65535,16-e%16),16-e%16)end
local function c(e)return n.band(n.bnot(u(e)),65535)end
local function l(n)return(n==FAMILY_INET4)and 32 or 128
end
local function f(n)return(n==FAMILY_INET4)and 30 or 127
end
function htons(e)if LITTLE_ENDIAN then
return n.bor(n.rshift(e,8),n.band(n.lshift(e,8),65280))else
return e
end
end
function htonl(e)if LITTLE_ENDIAN then
return n.bor(n.lshift(htons(n.band(e,65535)),16),htons(n.rshift(e,16)))else
return e
end
end
ntohs=htons
ntohl=htonl
function IPv4(e,r)e=e or"0.0.0.0/0"local i=i({FAMILY_INET4})local n={}local n=e:match("/(.+)")e=e:gsub("/.+","")e=e:gsub("^%[(.*)%]$","%1"):upper():gsub("^::FFFF:","")if r then
n=i:prefix(r)elseif n then
n=tonumber(n)if not n or n<0 or n>32 then return nil end
else
n=32
end
local t,r,e,d=e:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")t=tonumber(t)r=tonumber(r)e=tonumber(e)d=tonumber(d)if t and t<=255 and
r and r<=255 and
e and e<=255 and
d and d<=255 and
n
then
table.insert(i,{t*256+r,e*256+d})table.insert(i,n)return i
end
end
function IPv6(t,e)t=t or"::/0"local l=i({FAMILY_INET6})local n={}local d=t:match("/(.+)")t=t:gsub("/.+","")t=t:gsub("^%[(.*)%]$","%1")if e then
d=l:prefix(e)elseif d then
d=tonumber(d)if not d or d<0 or d>128 then return nil end
else
d=128
end
local i=t:sub(1,1)==":"and 2 or 1
local e,a,o,r,u
if#t>45 then return nil end
repeat
e=t:find(":",i,true)if not e then break end
r=tonumber(t:sub(i,e-1),16)if r and r<=65535 then
n[#n+1]=r
else
if a or e-i>1 then return nil end
a=#n+1
end
i=e+1
until#n==7
o=t:sub(i)if#o>0 and#o<=4 then
r=tonumber(o,16)if not r or r>65535 then return nil end
n[#n+1]=r
elseif#o>4 then
if#n==7 or#o>15 then return nil end
i=1
for t=1,4 do
e=o:find(".",i,true)if not e and t<4 then return nil end
e=e and e-1
r=tonumber(o:sub(i,e))if not r or r>255 then return nil end
if t==1 or t==3 then
n[#n+1]=r*256
else
n[#n]=n[#n]+r
end
i=e and e+2
end
end
if a then
if#n==8 then return nil end
while#n<8 do
table.insert(n,a,0)end
end
if#n==8 and d then
table.insert(l,n)table.insert(l,d)return l
end
end
function Hex(e,d,r,t)r=(r~=nil)and r or FAMILY_INET4
t=(t==nil)and true or t
d=d or l(r)local l=l(r)local n=""local o={}local a
for e=1,(l/4)-#e do n=n..'0'end
if t and LITTLE_ENDIAN then
for r=#e,1,-2 do n=n..e:sub(r-1,r)end
else
n=n..e
end
e=n
for n=1,(l/4),4 do
local n=tonumber(e:sub(n,n+3),16)if n then
o[#o+1]=n
else
return nil
end
end
return i({r,o,d})end
cidr=h.class()function cidr.is4(n)return n[1]==FAMILY_INET4
end
function cidr.is4rfc1918(n)if n[1]==FAMILY_INET4 then
return((n[2][1]>=2560)and(n[2][1]<=2815))or((n[2][1]>=44048)and(n[2][1]<=44063))or(n[2][1]==49320)end
return false
end
function cidr.is4linklocal(n)if n[1]==FAMILY_INET4 then
return(n[2][1]==43518)end
return false
end
function cidr.is6(n)return n[1]==FAMILY_INET6
end
function cidr.is6linklocal(n)if n[1]==FAMILY_INET6 then
return(n[2][1]>=65152)and(n[2][1]<=65215)end
return false
end
function cidr.string(e)local r
if e:is4()then
r=string.format("%d.%d.%d.%d",n.rshift(e[2][1],8),n.band(e[2][1],255),n.rshift(e[2][2],8),n.band(e[2][2],255))if e[3]<32 then
r=r.."/"..e[3]end
elseif e:is6()then
r=string.format("%X:%X:%X:%X:%X:%X:%X:%X",unpack(e[2]))if e[3]<128 then
r=r.."/"..e[3]end
end
return r
end
function cidr.lower(n,r)assert(n[1]==r[1],"Can't compare IPv4 and IPv6 addresses")local e
for e=1,#n[2]do
if n[2][e]~=r[2][e]then
return n[2][e]<r[2][e]end
end
return false
end
function cidr.higher(e,r)assert(e[1]==r[1],"Can't compare IPv4 and IPv6 addresses")local n
for n=1,#e[2]do
if e[2][n]~=r[2][n]then
return e[2][n]>r[2][n]end
end
return false
end
function cidr.equal(n,r)assert(n[1]==r[1],"Can't compare IPv4 and IPv6 addresses")local e
for e=1,#n[2]do
if n[2][e]~=r[2][e]then
return false
end
end
return true
end
function cidr.prefix(t,r)local e=t[3]if r then
e=0
local d=false
local r=type(r)~="table"and(t:is4()and IPv4(r)or IPv6(r))or r
if not r then return nil end
local t,t
for r,t in ipairs(r[2])do
if t==65535 then
e=e+16
else
local r=n.lshift(1,15)while n.band(t,r)==r do
e=e+1
r=n.lshift(1,15-(e%16))end
break
end
end
end
return e
end
function cidr.network(r,t)local e={}t=t or r[3]local d
for n=1,math.floor(t/16)do
e[#e+1]=r[2][n]end
if#e<#r[2]then
e[#e+1]=n.band(r[2][1+#e],u(t))for n=#e+1,#r[2]do
e[#e+1]=0
end
end
return i({r[1],e,l(r[1])})end
function cidr.host(n)return i({n[1],n[2],l(n[1])})end
function cidr.mask(e,r)local n={}r=r or e[3]for e=1,math.floor(r/16)do
n[#n+1]=65535
end
if#n<#e[2]then
n[#n+1]=u(r)for e=#n+1,#e[2]do
n[#n+1]=0
end
end
return i({e[1],n,l(e[1])})end
function cidr.broadcast(r)if r[1]==FAMILY_INET4 then
local e={unpack(r[2])}local t=math.floor(r[3]/16)+1
if t<=#e then
e[t]=n.bor(e[t],c(r[3]))for n=t+1,#e do e[n]=65535 end
return i({r[1],e,l(r[1])})end
end
end
function cidr.contains(n,e)assert(n[1]==e[1],"Can't compare IPv4 and IPv6 addresses")if n:prefix()<=e:prefix()then
return n:network()==e:network(n:prefix())end
return false
end
function cidr.add(r,e,d)local n
local n={unpack(r[2])}local t=s(e,r[1])for e=#n,1,-1 do
local r=(#t>0)and table.remove(t,#t)or 0
if(n[e]+r)>65535 then
n[e]=(n[e]+r)%65535
if e>1 then
n[e-1]=n[e-1]+(r-n[e])else
return nil
end
else
n[e]=n[e]+r
end
end
if d then
r[2]=n
return r
else
return i({r[1],n,r[3]})end
end
function cidr.sub(r,e,d)local n
local n={unpack(r[2])}local t=s(e,r[1])for e=#n,1,-1 do
local r=(#t>0)and table.remove(t,#t)or 0
if(n[e]-r)<0 then
n[e]=(r-n[e])%65535
if e>1 then
n[e-1]=n[e-1]-(r+n[e])else
return nil
end
else
n[e]=n[e]-r
end
end
if d then
r[2]=n
return r
else
return i({r[1],n,r[3]})end
end
function cidr.minhost(n)if n[3]<=f(n[1])then
return n:network():add(1,true)end
end
function cidr.maxhost(r)if r[3]<=f(r[1])then
local e
local e={unpack(r[2])}local t=math.floor(r[3]/16)+1
e[t]=n.bor(e[t],c(r[3]))for n=t+1,#e do e[n]=65535 end
e=i({r[1],e,l(r[1])})if e[1]==FAMILY_INET4 then e:sub(1,true)end
return e
end
end
