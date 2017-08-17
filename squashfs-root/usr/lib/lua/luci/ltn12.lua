local o=require("string")local i=require("table")local n=_G
module("luci.ltn12")filter={}source={}sink={}pump={}BLOCKSIZE=2048
_VERSION="LTN12 1.0.1"function filter.cycle(t,r,i)n.assert(t)return function(n)local e
e,r=t(r,n,i)return e
end
end
function filter.chain(...)local l=i.getn(arg)local t,r=1,1
local i=""return function(e)i=e and i
while true do
if r==t then
e=arg[r](e)if e==""or t==l then return e
elseif e then r=r+1
else
t=t+1
r=t
end
else
e=arg[r](e or"")if e==""then
r=r-1
e=i
elseif e then
if r==l then return e
else r=r+1 end
else n.error("filter returned inappropriate nil")end
end
end
end
end
local function e()return nil
end
function source.empty()return e
end
function source.error(e)return function()return nil,e
end
end
function source.file(e,r)if e then
return function()local n=e:read(BLOCKSIZE)if not n then e:close()end
return n
end
else return source.error(r or"unable to open file")end
end
function source.simplify(e)n.assert(e)return function()local n,r=e()e=r or e
if not n then return nil,r
else return n end
end
end
function source.string(n)if n then
local e=1
return function()local n=o.sub(n,e,e+BLOCKSIZE-1)e=e+BLOCKSIZE
if n~=""then return n
else return nil end
end
else return source.empty()end
end
function source.rewind(r)n.assert(r)local n={}return function(e)if not e then
e=i.remove(n)if not e then return r()else return e end
else
n[#n+1]=e
end
end
end
function source.chain(o,l)n.assert(o and l)local r,e="",""local i="feeding"local t
return function()if not e then
n.error('source is empty!',2)end
while true do
if i=="feeding"then
r,t=o()if t then return nil,t end
e=l(r)if not e then
if r then
n.error('filter returned inappropriate nil')else
return nil
end
elseif e~=""then
i="eating"if r then r=""end
return e
end
else
e=l(r)if e==""then
if r==""then
i="feeding"else
n.error('filter returned ""')end
elseif not e then
if r then
n.error('filter returned inappropriate nil')else
return nil
end
else
return e
end
end
end
end
end
function source.cat(...)local e=i.remove(arg,1)return function()while e do
local r,n=e()if r then return r end
if n then return nil,n end
e=i.remove(arg,1)end
end
end
function sink.table(e)e=e or{}local n=function(n,r)if n then e[#e+1]=n end
return 1
end
return n,e
end
function sink.simplify(e)n.assert(e)return function(r,n)local r,n=e(r,n)if not r then return nil,n end
e=n or e
return 1
end
end
function sink.file(e,r)if e then
return function(n,r)if not n then
e:close()return 1
else return e:write(n)end
end
else return sink.error(r or"unable to open file")end
end
local function e()return 1
end
function sink.null()return e
end
function sink.error(e)return function()return nil,e
end
end
function sink.chain(e,t)n.assert(e and t)return function(r,i)if r~=""then
local n=e(r)local r=r and""while true do
local i,t=t(n,i)if not i then return nil,t end
if n==r then return 1 end
n=e(r)end
else return 1 end
end
end
function pump.step(e,r)local n,e=e()local r,t=r(n,e)if n and r then return 1
else return nil,e or t end
end
function pump.all(r,t,e)n.assert(r and t)e=e or pump.step
while true do
local n,e=e(r,t)if not n then
if e then return nil,e
else return 1 end
end
end
end
