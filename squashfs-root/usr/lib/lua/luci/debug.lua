local e=require"debug"local o=require"io"local i,a=collectgarbage,math.floor
module"luci.debug"__file__=e.getinfo(1,'S').source:sub(2)function trap_memtrace(t,l)t=t or"clr"local n=o.open(l or"/tmp/memtrace","w")local l=0
local function u(c,r)local o=e.getinfo(2,"Sn")local t=a(i("count"))if t>l then
l=t
end
if n then
n:write("[",c,"] ",o.source,":",(r or"?"),"\t",(o.namewhat or""),"\t",(o.name or""),"\t",t," (",l,")\n")end
end
e.sethook(u,t)return function()e.sethook()n:close()end
end
