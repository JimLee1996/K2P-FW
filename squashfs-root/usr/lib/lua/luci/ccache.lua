local s=require"io"local l=require"nixio.fs"local f=require"debug"local i=require"string"local c=require"package"local n,m,o=type,loadfile,unpack
local d,_,h=pairs,math,setmetatable
local u,e=loadstring,getmetatable
module"luci.ccache"e("").__mod=function(r,e)if not e then
return r
elseif n(e)=="table"then
for t,r in d(e)do if n(e[t])=="userdata"then e[t]=tostring(e[t])end end
return r:format(o(e))else
if n(e)=="userdata"then e=tostring(e)end
return r:format(e)end
end
function _serialize_table(a,o)assert(not o[a],"Recursion detected.")o[a]=true
local r=""local t=""local l=0
for e,t in d(a)do
if n(e)~="number"or e<1 or _.floor(e)~=e or(e-#a)>3 then
e=serialize_data(e,o)t=serialize_data(t,o)r=r..(#r>0 and", "or"")..'['..e..'] = '..t
elseif e>l then
l=e
end
end
for e=1,l do
local e=serialize_data(a[e],o)t=t..(#t>0 and", "or"")..e
end
return t..(#r>0 and#t>0 and", "or"")..r
end
function serialize_data(e,t)t=t or h({},{__mode="k"})if e==nil then
return"nil"elseif n(e)=="number"then
return e
elseif n(e)=="string"then
return"%q"%e
elseif n(e)=="boolean"then
return e and"true"or"false"elseif n(e)=="function"then
return"loadstring(%q)"%get_bytecode(e)elseif n(e)=="table"then
return"{ ".._serialize_table(e,t).." }"else
return'"[unhandled data type:'..n(e)..']"'end
end
function restore_data(e)return u("return "..e)()end
function get_bytecode(t)local e
if n(t)=="function"then
e=i.dump(t)else
e=i.dump(u("return "..serialize_data(t)))end
return e
end
function cache_ondemand(...)if f.getinfo(1,'S').source~="=?"then
cache_enable(...)end
end
function cache_enable(e,t)e=e or"/tmp/luci-modulecache"t=t or"r--r--r--"local d=c.loaders[2]if not l.stat(e)then
l.mkdir(e)end
local function u(n)local e=""for t=1,#n do
e=e..("%2X"%i.byte(n,t))end
return e
end
local function o(e)local n=l.stat(e)if n then
return m(e)end
end
local function a(n,r)local e=s.open(n,"w")if e then
e:write(get_bytecode(r))e:close()l.chmod(n,t)end
end
c.loaders[2]=function(t)local r=e.."/"..u(t)local e=o(r)if e then
return e
end
e=d(t)if n(e)=="function"then
a(r,e)end
return e
end
end
