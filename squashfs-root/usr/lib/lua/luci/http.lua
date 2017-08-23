local e=require"luci.ltn12"local t=require"luci.http.protocol"local n=require"luci.util"local s=require"string"local e=require"coroutine"local a=require"table"local c,r,i,o,u,d=ipairs,pairs,next,type,tostring,error
local l=print
module"luci.http"context=n.threadlocal()Request=n.class()function Request.__init__(e,n,r,o)e.input=r
e.error=o
e.filehandler=function()end
e.message={env=n,headers={},params=t.urldecode_params(n.QUERY_STRING or""),json=nil,raw_data=nil}e.parsed_input=false
end
function Request.formvalue(e,n,t)if not t and not e.parsed_input then
e:_parse_input()end
if n then
return e.message.params[n]else
return e.message.params
end
end
function Request.formvaluetable(n,e)local t={}e=e and e.."."or"."if not n.parsed_input then
n:_parse_input()end
local o=n.message.params[nil]for n,r in r(n.message.params)do
if n:find(e,1,true)==1 then
t[n:sub(#e+1)]=u(r)end
end
return t
end
function Request.jsondata(e)if not e.parsed_input then
e:_parse_input()end
return e.message.json
end
function Request.get_raw_data(e)if not e.parsed_input then
e:_parse_input()end
return e.message.raw_data
end
function Request.content(e)if not e.parsed_input then
e:_parse_input()end
return e.message.content,e.message.content_length
end
function Request.getcookie(n,e)local n=s.gsub(";"..(n:getenv("HTTP_COOKIE")or"")..";","%s*;%s*",";")local e=";"..e.."=(.-);"local n,n,e=n:find(e)return e and urldecode(e)end
function Request.getenv(n,e)if e then
return n.message.env[e]else
return n.message.env
end
end
function Request.setfilehandler(e,n)e.filehandler=n
end
function Request._parse_input(e)t.parse_message_body(e.input,e.message,e.filehandler)e.parsed_input=true
end
function close()if not context.eoh then
context.eoh=true
e.yield(3)end
if not context.closed then
context.closed=true
e.yield(5)end
end
function content()return context.request:content()end
function formvalue(n,e)return context.request:formvalue(n,e)end
function formvaluetable(e)return context.request:formvaluetable(e)end
function jsondata()return context.request:jsondata()end
function get_raw_data()return context.request:get_raw_data()end
function formvalue(e,n)return context.request:formvalue(e,n)end
function getcookie(e)return context.request:getcookie(e)end
function getenv(e)return context.request:getenv(e)end
function setfilehandler(e)return context.request:setfilehandler(e)end
function header(n,t)if not context.headers then
context.headers={}end
context.headers[n:lower()]=t
e.yield(2,n,t)end
function prepare_content(e)if not context.headers or not context.headers["content-type"]then
if e=="application/xhtml+xml"then
if not getenv("HTTP_ACCEPT")or
not getenv("HTTP_ACCEPT"):find("application/xhtml+xml",nil,true)then
e="text/html; charset=UTF-8"end
header("Vary","Accept")end
header("Content-Type",e)end
end
function source()return context.request.input
end
function status(n,t)n=n or 200
t=t or"OK"context.status=n
e.yield(1,n,t)end
function write(n,t)if not n then
if t then
d(t)else
close()end
return true
elseif#n==0 then
return true
else
if not context.eoh then
if not context.status then
status()end
if not context.headers or not context.headers["content-type"]then
header("Content-Type","text/html; charset=utf-8")end
if not context.headers["cache-control"]then
header("Cache-Control","no-cache")header("Expires","0")end
context.eoh=true
e.yield(3)end
e.yield(4,n)return true
end
end
function splice(n,t)e.yield(6,n,t)end
function redirect(e)status(302,"Found")header("Location",e)close()end
function build_querystring(n)local e={"?"}for t,n in r(n)do
if#e>1 then e[#e+1]="&"end
e[#e+1]=urldecode(t)e[#e+1]="="e[#e+1]=urldecode(n)end
return a.concat(e,"")end
urldecode=t.urldecode
urlencode=t.urlencode
function json_escape(e)return e:gsub('\\','\\\\'):gsub('"','\\"')end
function write_json(e,n)if e==nil then
write("null")elseif o(e)=="table"then
local t,t
if#e==0 and i(e)then
write("{")for t,r in r(e)do
write("%q:"%t)write_json(r,n)if i(e,t)then
write(",")end
end
write("}")else
write("[")for t,r in c(e)do
write_json(r,n)if i(e,t)then
write(",")end
end
write("]")end
elseif o(e)=="number"or o(e)=="boolean"then
if(e~=e)then
write("Number.NaN")else
write(u(e))end
else
local e=e
if n then
e=n(e)end
write('"%s"'%e)end
end
