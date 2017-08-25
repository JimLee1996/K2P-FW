module("luci.http.protocol.conditionals",package.seeall)local e=require("luci.http.protocol.date")function mk_etag(e)if e~=nil then
return string.format('"%x-%x-%x"',e.ino,e.size,e.mtime)end
end
function if_match(e,n)local e=e.headers
local t=mk_etag(n)if type(e['If-Match'])=="string"then
for e in e['If-Match']:gmatch("([^, ]+)")do
if(e=='*'or e==t)and n~=nil then
return true
end
end
return false,412
end
return true
end
function if_modified_since(t,n)local t=t.headers
if type(t['If-Modified-Since'])=="string"then
local t=e.to_unix(t['If-Modified-Since'])if n==nil or t<n.mtime then
return true
end
return false,304,{["ETag"]=mk_etag(n);["Date"]=e.to_http(os.time());["Last-Modified"]=e.to_http(n.mtime)}end
return true
end
function if_none_match(t,n)local i=t.headers
local o=mk_etag(n)local r=t.env and t.env.REQUEST_METHOD or"GET"if type(i['If-None-Match'])=="string"then
for t in i['If-None-Match']:gmatch("([^, ]+)")do
if(t=='*'or t==o)and n~=nil then
if r=="GET"or r=="HEAD"then
return false,304,{["ETag"]=o;["Date"]=e.to_http(os.time());["Last-Modified"]=e.to_http(n.mtime)}else
return false,412
end
end
end
end
return true
end
function if_range(e,e)return false,412
end
function if_unmodified_since(n,t)local n=n.headers
if type(n['If-Unmodified-Since'])=="string"then
local e=e.to_unix(n['If-Unmodified-Since'])if t~=nil and e<=t.mtime then
return false,412
end
end
return true
end
