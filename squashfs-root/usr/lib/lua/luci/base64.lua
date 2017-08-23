local e=require"string"local o=require"math"module"luci.base64"function encode(n)if(n==nil)then
return""end
local c='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'local d=''local l=n
while#l>0 do
local r=0
local n=0
for o=1,3 do
n=(n*256)if#l>0 then
n=n+e.byte(l,1,1)l=e.sub(l,2)r=r+1
end
end
for l=1,(r+1)do
b64char=o.fmod(o.floor(n/262144),64)+1
d=d..e.sub(c,b64char,b64char)n=n*64
end
for e=1,(3-r)do
d=d..'='end
end
return d
end
function decode(l)if(l==nil)then
return""end
local d='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'local r={}for n=1,64 do
r[e.sub(d,n,n)]=n
end
r['=']=0
local d=""for f=1,#l,4 do
if f>#l then
break
end
local n=0
local c=0
for o=0,3 do
local e=e.sub(l,f+o,f+o)if not r[e]then
return
end
if r[e]<1 then
n=n*64
else
n=n*64+r[e]-1
c=c+1
end
end
for l=16,0,-8 do
if c>0 then
d=d..e.char(o.floor(n/o.pow(2,l)))n=o.mod(n,o.pow(2,l))c=c-1
end
end
end
if e.find(l,"=")~=nil then
d=(e.sub(d,1,-2))end
return d
end
