local a=require"table"local t=require"nixio"local n,e,k,h=getmetatable,assert,pairs,type
local p=tostring
module"nixio.util"local r=t.const.buffersize
local f=65536
local u=t.meta_socket
local o=t.meta_tls_socket
local s=t.meta_file
local e=t.uname()local _=e.sysname=="Linux"and e.release:sub(1,3)=="2.4"function consume(e,n)local n=n or{}if e then
for e in e do
n[#n+1]=e
end
end
return n
end
local e={}function e.is_socket(e)return(n(e)==u)end
function e.is_tls_socket(e)return(n(e)==o)end
function e.is_file(e)return(n(e)==s)end
function e.readall(c,o)local n,d,i=c:read(o or r)if not n then
return nil,d,i,""elseif#n==0 then
return"",nil,nil,""end
local t,l={n},#n
while not o or o>l do
n,d,i=c:read(o and(o-l)or r)if not n then
return nil,d,i,a.concat(t)elseif#n==0 then
break
end
t[#t+1],l=n,l+#n
end
local n=#t>1 and a.concat(t)or t[1]return n,nil,nil,n
end
e.recvall=e.readall
function e.writeall(i,t)t=p(t)local o,r,l=i:write(t)if not o then
return nil,r,l,0
end
local n=o
while n<#t do
o,r,l=i:write(t,n)if not o then
return nil,r,l,n
end
n=n+o
end
return n,nil,nil,n
end
e.sendall=e.writeall
function e.linesource(d,o)o=o or r
local e=""local n=0
return function(l)local t,r,i
if l then
t=e:sub(n+1)e=h(l)=="string"and l or""n=0
return t
end
while not t do
i,r,t=e:find("(.-)\r?\n",n+1)if t then
n=r
return t
elseif#e<o+n then
local t,o,l=d:read(o+n-#e)if not t then
return nil,o,l
elseif#t==0 then
return nil
end
e=e:sub(n+1)..t
n=0
else
return nil,0
end
end
end
end
function e.blocksource(t,e,n)e=e or r
return function()local e=e
if n then
if n<1 then
return nil
elseif n<e then
e=n
end
end
local e,o,t=t:read(e)if not e then
return nil,o,t
elseif#e==0 then
return nil
else
if n then
n=n-#e
end
return e
end
end
end
function e.sink(n,t)return function(e,o)if not e and not o and t then
if n.shutdown then
n:shutdown()end
n:close()elseif e and#e>0 then
return n:writeall(e)end
return true
end
end
function e.copy(n,t,e)local l=n:blocksource(nil,e)local r=t:sink()local e,n,t,o=0
repeat
n,t,o=l()r(n,t,o)e=n and(e+#n)or e
until not n
return not t and e or nil,t,o,e
end
function e.copyz(i,r,e)local o,n,l,a=0
local d
if not _ and i:is_file()then
local c=i:stat("type")if t.sendfile and r:is_socket()and c=="reg"then
repeat
n,l,a=t.sendfile(r,i,e or f)if n then
o=o+n
e=e and(e-n)end
until(not n or n==0 or(e and e==0))if n or(not n and o==0 and
l~=t.const.ENOSYS and l~=t.const.EINVAL)then
return n and o,l,a,o
end
elseif t.splice and not r:is_tls_socket()and c=="fifo"then
d=true
end
end
if t.splice and r:is_file()and not d then
d=not i:is_tls_socket()and r:stat("type")=="fifo"end
if d then
repeat
n,l,a=t.splice(i,r,e or f)if n then
o=o+n
e=e and(e-n)end
until(not n or n==0 or(e and e==0))if n or(not n and o==0 and
l~=t.const.ENOSYS and l~=t.const.EINVAL)then
return n and o,l,a,o
end
end
return i:copy(r,e)end
if o then
function o.close(n)return n.socket:close()end
function o.getsockname(n)return n.socket:getsockname()end
function o.getpeername(n)return n.socket:getpeername()end
function o.getsockopt(n,...)return n.socket:getsockopt(...)end
o.getopt=o.getsockopt
function o.setsockopt(n,...)return n.socket:setsockopt(...)end
o.setopt=o.setsockopt
end
for n,e in k(e)do
s[n]=e
u[n]=e
if o then
o[n]=e
end
end
