local e=require"table"local e=require"nixio"local d,t,n=type,ipairs,setmetatable
require"nixio.util"module("nixio.fs",function(t)n(t,{__index=e.fs})end)function readfile(n,o)local n,e,t=e.open(n,"r")local r
if not n then
return nil,e,t
end
r,e,t=n:readall(o)n:close()return r,e,t
end
function writefile(n,o)local e,t,n,r=e.open(n,"w")if not e then
return nil,t,n
end
r,t,n=e:writeall(o)e:close()return r,t,n
end
function datacopy(n,r,t)local n,i,o=e.open(n,"r")if not n then
return nil,i,o
end
local e,o,r=e.open(r,"w")if not e then
return nil,o,r
end
local o,i,t,r=n:copy(e,t)n:close()e:close()return o,i,t,r
end
function copy(l,t)local n,r,o,i=e.fs.lstat(l)if not n then
return nil,r,o
end
if n.type=="dir"then
if e.fs.stat(t,d)~="dir"then
i,r,o=e.fs.mkdir(t)else
n=true
end
elseif n.type=="lnk"then
i,r,o=e.fs.symlink(e.fs.readlink(l),t)elseif n.type=="reg"then
i,r,o=datacopy(l,t)end
if not i then
return nil,r,o
end
e.fs.utimes(t,n.atime,n.mtime)if e.fs.lchown then
e.fs.lchown(t,n.uid,n.gid)end
if n.type~="lnk"then
e.fs.chmod(t,n.modedec)end
return true
end
function move(o,i)local n,t,r=e.fs.rename(o,i)if not n and t==e.const.EXDEV then
n,t,r=copy(o,i)if n then
n,t,r=e.fs.unlink(o)end
end
return n,t,r
end
function mkdirr(r,o)if e.fs.stat(r,"type")=="dir"then
return true
else
local n,t,i=e.fs.mkdir(r,o)if not n and t==e.const.ENOENT then
n,t,i=mkdirr(e.fs.dirname(r),o)if n then
n,t,i=e.fs.mkdir(r,o)end
end
return n,t,i
end
end
local function c(s,l,f)local n=e.fs.lstat(l,"type")if n~="dir"then
return s(l,f)else
local o,a,i,r,n,t,d=true,e.const.sep
if f then
n,t,d=s(l,f)o,i,r=o and n,t or i,d or r
end
for e in e.fs.dir(l)do
if f then
n,t,d=c(s,l..a..e,f..a..e)else
n,t,d=c(s,l..a..e)end
o,i,r=o and n,t or i,d or r
end
if not f then
n,t,d=s(l)o,i,r=o and n,t or i,d or r
end
return o,i,r
end
end
function copyr(n,e)return c(copy,n,e)end
function mover(o,i)local n,t,r=e.fs.rename(o,i)if not n and t==e.const.EXDEV then
n,t,r=c(copy,o,i)if n then
n,t,r=c(e.fs.remove,o)end
end
return n,t,r
end
function remover(n)return c(e.fs.remove,n)end