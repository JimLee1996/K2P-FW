module("luci.http.protocol",package.seeall)local o=require("luci.ltn12")local m=require("luci.json")HTTP_MAX_CONTENT=1024*8
function urldecode(e,t)local function n(e)return string.char(tonumber(e,16))end
if type(e)=="string"then
if not t then
e=e:gsub("+"," ")end
e=e:gsub("%%([a-fA-F0-9][a-fA-F0-9])",n)end
return e
end
function urldecode_params(e,n)local n=n or{}if e:find("?")then
e=e:gsub("^.+%?([^?]+)","%1")end
for t in e:gmatch("[^&;]+")do
local e=urldecode(t:match("^([^=]+)"))local t=urldecode(t:match("^[^=]+=(.+)$"))if type(e)=="string"and e:len()>0 then
if type(t)~="string"then t=""end
if not n[e]then
n[e]=t
elseif type(n[e])~="table"then
n[e]={n[e],t}else
table.insert(n[e],t)end
end
end
return n
end
function urlencode(e)local function n(e)return string.format("%%%02x",string.byte(e))end
if type(e)=="string"then
e=e:gsub("([^a-zA-Z0-9$_%-%.%+!*'(),])",n)end
return e
end
function urlencode_params(n)local e=""for t,n in pairs(n)do
if type(n)=="table"then
for r,n in ipairs(n)do
e=e..(#e>0 and"&"or"")..urlencode(t).."="..urlencode(n)end
else
e=e..(#e>0 and"&"or"")..urlencode(t).."="..urlencode(n)end
end
return e
end
local function c(n,e)if n[e]==nil then
n[e]=""elseif type(n[e])=="string"then
n[e]={n[e],""}else
table.insert(n[e],"")end
end
local function s(n,e,t)if type(n[e])=="table"then
n[e][#n[e]]=n[e][#n[e]]..t
else
n[e]=n[e]..t
end
end
local function f(e,n,t)if t then
if type(e[n])=="table"then
e[n][#e[n]]=t(e[n][#e[n]])else
e[n]=t(e[n])end
end
end
local i={}i['magic']=function(e,n,t)if n~=nil then
if#n==0 then
return true,nil
end
local t,r,o=n:match("^([A-Z]+) ([^ ]+) HTTP/([01]%.[019])$")if t then
e.type="request"e.request_method=t:lower()e.request_uri=r
e.http_version=tonumber(o)e.headers={}return true,function(n)return i['headers'](e,n)end
else
local r,n,t=n:match("^HTTP/([01]%.[019]) ([0-9]+) ([^\r\n]+)$")if n then
e.type="response"e.status_code=n
e.status_message=t
e.http_version=tonumber(r)e.headers={}return true,function(n)return i['headers'](e,n)end
end
end
end
return nil,"Invalid HTTP message magic"end
i['headers']=function(r,t)if t~=nil then
local e,n=t:match("^([A-Za-z][A-Za-z0-9%-_]+): +(.+)$")if type(e)=="string"and e:len()>0 and
type(n)=="string"and n:len()>0
then
r.headers[e]=n
return true,nil
elseif#t==0 then
return false,nil
else
return nil,"Invalid HTTP header received"end
else
return nil,"Unexpected EOF"end
end
function header_source(e)return o.source.simplify(function()local e,n,t=e:receive("*l")if e==nil then
if n~="timeout"then
return nil,t
and"Line exceeds maximum allowed length"or"Unexpected EOF"else
return nil,n
end
elseif e~=nil then
e=e:gsub("\r$","")return e,nil
end
end)end
function mimedecode_message_body(h,n,u)if n and n.env.CONTENT_TYPE then
n.mime_boundary=n.env.CONTENT_TYPE:match("^multipart/form%-data; boundary=(.+)$")end
if not n.mime_boundary then
return nil,"Invalid Content-Type found"end
local a=0
local i=false
local r=nil
local l=nil
local t=nil
local function d(t,e)local r
repeat
t,r=t:gsub("^([A-Z][A-Za-z0-9%-_]+): +([^\r\n]+)\r\n",function(t,n)e.headers[t]=n
return""end)until r==0
t,r=t:gsub("^\r\n","")if r>0 then
if e.headers["Content-Disposition"]then
if e.headers["Content-Disposition"]:match("^form%-data; ")then
e.name=e.headers["Content-Disposition"]:match('name="(.-)"')e.file=e.headers["Content-Disposition"]:match('filename="(.+)"$')end
end
if not e.headers["Content-Type"]then
e.headers["Content-Type"]="text/plain"end
if e.name and e.file and u then
c(n.params,e.name)s(n.params,e.name,e.file)l=u
elseif e.name then
c(n.params,e.name)l=function(r,t,r)s(n.params,e.name,t)end
else
l=nil
end
return t,true
end
return t,false
end
local function c(o)a=a+(o and#o or 0)if n.env.CONTENT_LENGTH and a>tonumber(n.env.CONTENT_LENGTH)+2 then
return nil,"Message body size exceeds Content-Length"end
if o and not t then
t="\r\n"..o
elseif t then
local e=t..(o or"")local a,u,s
repeat
a,u=e:find("\r\n--"..n.mime_boundary.."\r\n",1,true)if not a then
a,u=e:find("\r\n--"..n.mime_boundary.."--\r\n",1,true)end
if a then
local n=e:sub(1,a-1)if i then
n,eof=d(n,r)if not eof then
return nil,"Invalid MIME section header"elseif not r.name then
return nil,"Invalid Content-Disposition header"end
end
if l then
l(r,n,true)end
r={headers={}}s=s or true
e,eof=d(e:sub(u+1,#e),r)i=not eof
end
until not a
if s then
t,e=e,nil
else
if i then
t,eof=d(e,r)i=not eof
else
l(r,t,false)t,o=o,nil
end
end
end
return true
end
return o.pump.all(h,c)end
function urldecode_message_body(i,n)local r=0
local t=nil
local a=""local function l(e)r=r+(e and#e or 0)if n.env.CONTENT_LENGTH and r>tonumber(n.env.CONTENT_LENGTH)+2 then
return nil,"Message body size exceeds Content-Length"elseif r>HTTP_MAX_CONTENT then
return nil,"Message body size exceeds maximum allowed length"end
a=a..(e or"")if not t and e then
t=e
elseif t then
local e=t..(e or"&")local r,o
repeat
r,o=e:find("^.-[;&]")if r then
local r=e:sub(r,o-1)local t=r:match("^(.-)=")local r=r:match("=([^%s]*)%s*$")if t and#t>0 then
c(n.params,t)s(n.params,t,r)f(n.params,t,urldecode)end
e=e:sub(o+1,#e)end
until not r
t=e
end
return true
end
local e,t=o.pump.all(i,l)if not e then
return e,t
end
n.raw_data=a
return true
end
function jsondecode_message_body(l,e)local t=0
local n=""local function a(r)t=t+(r and#r or 0)if e.env.CONTENT_LENGTH and t>tonumber(e.env.CONTENT_LENGTH)+2 then
return nil,"Message body size exceeds Content-Length"elseif t>HTTP_MAX_CONTENT then
return nil,"Message body size exceeds maximum allowed length"end
n=n..(r or"")return true
end
local t,r=o.pump.all(l,a)if not t then
return t,r
end
e.raw_data=n
local n=m.decode(n,urldecode)if not n then
return nil,"Message body is not legal json string"end
e.json=n
return true
end
function parse_message_header(t)local n=true
local e={}local r=o.sink.simplify(function(n)return i['magic'](e,n)end)while n do
n,err=o.pump.step(t,r)if not n and err then
return nil,err
elseif not n then
if(e.request_method=="get"or e.request_method=="post")and
e.request_uri:match("?")then
e.params=urldecode_params(e.request_uri)else
e.params={}end
e.env={CONTENT_LENGTH=e.headers['Content-Length'];CONTENT_TYPE=e.headers['Content-Type']or e.headers['Content-type'];REQUEST_METHOD=e.request_method:upper();REQUEST_URI=e.request_uri;SCRIPT_NAME=e.request_uri:gsub("?.+$","");SCRIPT_FILENAME="";SERVER_PROTOCOL="HTTP/"..string.format("%.1f",e.http_version);QUERY_STRING=e.request_uri:match("?")and e.request_uri:gsub("^.+?","")or""}for t,n in ipairs({'Accept','Accept-Charset','Accept-Encoding','Accept-Language','Connection','Cookie','Host','Referer','User-Agent',})do
local t='HTTP_'..n:upper():gsub("%-","_")local n=e.headers[n]e.env[t]=n
end
end
end
return e
end
function parse_message_body(t,e,n)if e.env.REQUEST_METHOD=="POST"and e.env.CONTENT_TYPE and
e.env.CONTENT_TYPE:match("^multipart/form%-data")then
return mimedecode_message_body(t,e,n)elseif e.env.REQUEST_METHOD=="POST"and e.env.CONTENT_TYPE and
e.env.CONTENT_TYPE:match("^application/x%-www%-form%-urlencoded")then
return urldecode_message_body(t,e,n)elseif e.env.REQUEST_METHOD=="POST"and e.env.CONTENT_TYPE and
e.env.CONTENT_TYPE:match("^application/json")then
return jsondecode_message_body(t,e,n)else
local r
if type(n)=="function"then
r=n
else
e.content=""e.content_length=0
r=function(n,t)if n then
if(e.content_length+#n)<=HTTP_MAX_CONTENT then
e.content=e.content..n
e.content_length=e.content_length+#n
return true
else
return nil,"POST data exceeds maximum allowed length"end
end
return true
end
end
while true do
local n,e=o.pump.step(t,r)if not n and e then
return nil,e
elseif not e then
return true
end
end
return true
end
end
statusmsg={[200]="OK",[206]="Partial Content",[301]="Moved Permanently",[302]="Found",[304]="Not Modified",[400]="Bad Request",[403]="Forbidden",[404]="Not Found",[405]="Method Not Allowed",[408]="Request Time-out",[411]="Length Required",[412]="Precondition Failed",[416]="Requested range not satisfiable",[500]="Internal Server Error",[503]="Server Unavailable",}