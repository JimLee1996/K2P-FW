local a=require"os"local r=require"io"local t=require"nixio.fs"local e=require"luci.util"local d=type
local n=pairs
local l=error
local e=table
local i="opkg --force-removal-of-dependent-packages --force-overwrite --nocase"local c="/etc/opkg.conf"module"luci.model.ipkg"local function o(l,...)local e=""for l,n in n({...})do
e=e.." '"..n:gsub("'","").."'"end
local e="%s %s %s >/tmp/opkg.stdout 2>/tmp/opkg.stderr"%{i,l,e}local l=a.execute(e)local n=t.readfile("/tmp/opkg.stderr")local e=t.readfile("/tmp/opkg.stdout")t.unlink("/tmp/opkg.stderr")t.unlink("/tmp/opkg.stdout")return l,e or"",n or""end
local function u(n)if d(n)~="function"then
l("OPKG: Invalid rawdata given")end
local a={}local e={}local t=nil
for o in n do
if o:sub(1,1)~=" "then
local n,l=o:match("(.-): ?(.*)%s*")if n and l then
if n=="Package"then
e={Package=l}a[l]=e
elseif n=="Status"then
e.Status={}for n in l:gmatch("([^ ]+)")do
e.Status[n]=true
end
else
e[n]=l
end
t=n
end
else
e[t]=e[t].."\n"..o
end
end
return a
end
local function l(n,e)local n=i.." "..n
if e then
n=n.." '"..e:gsub("'","").."'"end
local e=a.tmpname()a.execute(n..(" >%s 2>/dev/null"%e))local n=u(r.lines(e))a.remove(e)return n
end
function info(e)return l("info",e)end
function status(e)return l("status",e)end
function install(...)return o("install",...)end
function installed(e)local e=status(e)[e]return(e and e.Status and e.Status.installed)end
function remove(...)return o("remove",...)end
function update()return o("update")end
function upgrade()return o("upgrade")end
function _list(n,e,a)local o=r.popen(i.." "..n..(e and(" '%s'"%e:gsub("'",""))or""))if o then
local e,n,l
while true do
local t=o:read("*l")if not t then break end
e,n,l=t:match("^(.-) %- (.-) %- (.+)")if not e then
e,n=t:match("^(.-) %- (.+)")l=""end
a(e,n,l)e=nil
n=nil
l=nil
end
o:close()end
end
function list_all(e,n)_list("list",e,n)end
function list_installed(n,e)_list("list_installed",n,e)end
function find(n,e)_list("find",n,e)end
function overlay_root()local n="/"local l=r.open(c,"r")if l then
local e
repeat
e=l:read("*l")if e and e:match("^%s*option%s+overlay_root%s+")then
n=e:match("^%s*option%s+overlay_root%s+(%S+)")local e=t.stat(n)if not e or e.type~="dir"then
n="/"end
break
end
until not e
l:close()end
return n
end
