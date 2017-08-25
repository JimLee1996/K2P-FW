local l,i=require,pairs
local t,e,e=string,ipairs,io
local n=l("luci.phicomm.error")local c=l("luci.fs")local e=l("luci.util")local l=l("luci.phicomm.lib.shell")local e=print
local o="luci.phicomm.fs"local e={}_G[o]=e
package.loaded[o]=e
setmetatable(e,{__index=c})setfenv(1,e)function copy(c,o,e)local n=e or false
local e="-R"if n then
e=e.."f"end
local e={"cp",e,c,o}local e=l.construct_cmd(e)return l.execute_cmd(e)end
function remove(o,e)if not c.isdirectory(o)then
return n.E_NONE
end
local c=e or false
local e="-r"if c then
e=e.."f"end
local e={"rm",e,o}local e=l.construct_cmd(e)return l.execute_cmd(e)end
function get_pat_file(l,o)if l==nil or o==nil then
return{}end
local e=c.dir(l)if e==nil then
return{}end
local l={}for c,e in i(e)do
if t.match(e,o)then
l[#l+1]=e
end
end
return l
end
