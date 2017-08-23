local n,n=_G,os
local r,n,u=require,type,math
local e,c,a,l=string,ipairs,pairs,io
local o,t,l=table,tonumber,tostring
local l=r("nixio")local i=r("luci.util")local d=r("luci.phicomm.lib.bit").bit
module"luci.phicomm.util"function oct2hex(e)if n(e)~="number"then
return nil
end
if e==0 then
return 0
end
local l=""local n=e
local e={"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}while n>0 do
l=e[n%16+1]..l
n=u.floor(n/16)end
return l
end
function equal(e,l)if e==nil and l==nil then
return true
end
if n(e)~=n(l)then
return false
end
if n(e)~="table"then
return e==l
end
local n=i.keys(e)local t=i.keys(l)if#n~=#t then
return false
end
for t,n in c(n)do
if not equal(e[n],l[n])then
return false
end
end
return true
end
function handle_special_char(t)local n=""local i={[" "]="%s"}local l="^$()%.[]*+-?"for t=1,#l do
n=e.sub(l,t,t)i[n]="%"..n
end
local l=""for r=1,#t do
n=e.sub(t,r,r)l=l..(i[n]or n)end
return l
end
function split_string(r,t)if n(r)~="string"or n(t)~="string"then
return nil
end
if#t~=1 then
return nil
end
local l={}local n=handle_special_char(t)local o=e.format("%s",n)local n=r
local t,r=e.find(n,o)local i=""while t do
if t==1 then
i=""else
i=e.sub(n,1,t-1)end
l[#l+1]=e.gsub(i,"%s*(.+)%s*","%1")if r==#n then
n=""break
end
n=e.sub(n,r+1,#n)t,r=e.find(n,o)end
l[#l+1]=e.gsub(n,"%s*(.+)%s*","%1")return l
end
function split_module_func(l)if n(l)~="string"then
return nil,nil
end
local n={}for e in e.gmatch(l,"([%w-_]+)")do
n[#n+1]=e
end
local e=o.remove(n,#n)local n=#n>0 and o.concat(n,".")or nil
return n,e
end
function get_network(l,e)if n(l)~="string"or n(e)~="string"then
return nil
end
local n=split_string(l,".")local r=split_string(e,".")if#n~=4 and#r~=4 then
return nil
end
local e={}for l,i in c(n)do
local n=d:bit_and(t(n[l]),t(r[l]))e[#e+1]=n
end
return o.concat(e,".")end
function utf8_truncate(l,r)if n(l)~="string"or n(r)~="number"then
return nil,nil
end
if r<=0 then
return l,#l
end
if#l<=r then
return l,#l
end
local a=t("0x80",16)local o=t("0xC0",16)local i=t("0xFD",16)for n=0,5 do
local n=r-n+1
if n<=0 then
break
end
local t=e.byte(l,n,n)if a~=d:bit_and(t,o)then
if t>i then
break
end
local n=e.sub(l,1,n-1)return n,#n
end
end
local n=e.sub(l,1,r)return n,#n
end
function index(e,l)if n(e)~="table"or l==nil then
return nil
end
for n,e in a(e)do
if e==l then
return n
end
end
return nil
end
function fork_exec(e)local n=l.fork()if n>0 then
return
elseif n==0 then
l.chdir("/")local n=l.open("/dev/null","w+")if n then
l.dup(n,l.stderr)l.dup(n,l.stdout)l.dup(n,l.stdin)if n:fileno()>2 then
n:close()end
end
l.exec("/bin/sh","-c",e)end
end
function merge_table(e,l)if"table"~=n(e)or"table"~=n(l)then
do return e end
end
for l,n in a(l)do
e[l]=n
end
return e
end
