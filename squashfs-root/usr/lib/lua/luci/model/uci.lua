local i=require"os"local e=require"io"local e=require"uci"local d=require"luci.util"local a=require"table"local n,n,n=setmetatable,rawget,rawset
local o,r=require,getmetatable
local t,l,n=error,pairs,ipairs
local t,c,s,u=type,tostring,tonumber,unpack
module"luci.model.uci"cursor=e.cursor
APIVERSION=e.APIVERSION
function cursor_state()return cursor(nil,"/var/state")end
inst=cursor()inst_state=cursor_state()local e=r(inst)function e.apply(n,e,t,r)e=n:_affected(e)if t then
return{"/sbin/luci-reload",u(e)}else
local t="/sbin/luci-reload %s >/dev/null 2>&1"%a.concat(e," ")if r then
local e=o("nixio")local n=e.fork()if n>0 then
return
elseif n==0 then
e.chdir("/")e.exec("/bin/sh","-c",t)end
else
return i.execute(t)end
end
end
function e.delete_all(o,a,u,e)local r={}if t(e)=="table"then
local n=e
e=function(e)for n,t in l(n)do
if e[n]~=t then
return false
end
end
return true
end
end
local function t(n)if not e or e(n)then
r[#r+1]=n[".name"]end
end
o:foreach(a,u,t)for n,e in n(r)do
o:delete(a,e)end
end
function e.section(t,r,a,e,o)local n=true
if e then
n=t:set(r,e,a)else
e=t:add(r,a)n=e and true
end
if n and o then
n=t:tset(r,e,o)end
return n and e
end
function e.tset(t,a,r,n)local e=true
for n,o in l(n)do
if n:sub(1,1)~="."then
e=e and t:set(a,r,n,o)end
end
return e
end
function e.get_bool(e,...)local e=e:get(...)return(e=="1"or e=="true"or e=="yes"or e=="on")end
function e.get_list(o,n,e,r)if n and e and r then
local e=o:get(n,e,r)return(t(e)=="table"and e or{e})end
return nil
end
function e.get_first(o,a,l,e,n)local r=n
o:foreach(a,l,function(o)local e=not e and o['.name']or o[e]if t(n)=="number"then
e=s(e)elseif t(n)=="boolean"then
e=(e=="1"or e=="true"or
e=="yes"or e=="on")end
if e~=nil then
r=e
return false
end
end)return r
end
function e.set_list(a,n,o,r,e)if n and o and r then
return a:set(n,o,r,(t(e)=="table"and e or{e}))end
return false
end
function e._affected(r,e)e=t(e)=="table"and e or{e}local a=cursor()a:load("ucitrack")local t={}local function r(o)local t={o}local e={}a:foreach("ucitrack",o,function(t)if t.affects then
for t,n in n(t.affects)do
e[#e+1]=n
end
end
end)for o,e in n(e)do
for n,e in n(r(e))do
t[#t+1]=e
end
end
return t
end
for o,e in n(e)do
for n,e in n(r(e))do
if not d.contains(t,e)then
t[#t+1]=e
end
end
end
return t
end
function e.substate(n)e._substates=e._substates or{}e._substates[n]=e._substates[n]or cursor_state()return e._substates[n]end
local t=e.load
function e.load(n,...)if e._substates and e._substates[n]then
t(e._substates[n],...)end
return t(n,...)end
local t=e.unload
function e.unload(n,...)if e._substates and e._substates[n]then
t(e._substates[n],...)end
return t(n,...)end
