module("luci.sgi.cgi",package.seeall)local l=require("luci.ltn12")local e=require("nixio")require("luci.dispatcher")local function o(t,e)e=e or 0
local n=l.BLOCKSIZE
return function()if e<1 then
t:close()return nil
else
local n=(e>n)and n or e
e=e-n
local e=t:read(n)if not e then t:close()end
return e
end
end
end
local function r()local i=require("luci.sauth")local l=string.gsub(e.getenv("REMOTE_ADDR")or"x.x.x.x","%.","_")local t
local n=i.read(l)if n and n.token then
t=n.token
else
local e=require("luci.sys")t=luci.sys.uniqueid(16)i.write(l,{user="admin",token=t})end
local n=e.getenv("PATH_INFO")local t=string.format("/stok=%s%s",t,n)local n=e.getenv("SCRIPT_NAME")..t
e.setenv("PATH_INFO",t)e.setenv("REQUEST_URI",n)end
function run()if e.getenv("PHIAPP_REQUEST")then
r()end
local n=luci.http.Request(e.getenv(),o(io.stdin,tonumber(e.getenv("CONTENT_LENGTH"))),l.sink.file(io.stderr))local t=coroutine.create(luci.dispatcher.httpdispatch)local l=""local o=true
while coroutine.status(t)~="dead"do
local r,t,n,i=coroutine.resume(t,n)if not r then
print("Status: 500 Internal Server Error")print("Content-Type: text/plain\n")print(t)break;end
if o then
if t==1 then
io.write("Status: "..tostring(n).." "..i.."\r\n")elseif t==2 then
l=l..n..": "..i.."\r\n"elseif t==3 then
io.write(l)io.write("\r\n")elseif t==4 then
io.write(tostring(n or""))elseif t==5 then
io.flush()io.close()o=false
elseif t==6 then
n:copyz(e.stdout,i)n:close()end
end
end
end
