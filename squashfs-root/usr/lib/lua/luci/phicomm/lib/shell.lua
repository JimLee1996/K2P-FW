local e=print
local l,t=require"os",io
local i=require"string"local o=require"table"local e,e,e=setmetatable,rawget,rawset
local e,e=require,getmetatable
local e,a,e=error,pairs,ipairs
local e,e,e,e=type,tostring,tonumber,unpack
module"luci.phicomm.lib.shell"CALL_SUCCESS_CODE=0
DEFAULT_KEY_VALUE_CONN_SYMBOL=" "DEFAULT_KWARG_ENTRY_CONN_SYMBOL=" "function keys(n)local e={}if nil==n then
return{}end
for n,l in a(n)do
e[#e+1]=n
end
return e
end
function execute_cmd(e)local e=l.execute(e)return e==CALL_SUCCESS_CODE
end
function async_execute(e)t.popen(e)return true
end
function construct_cmd(n,t,c,r,l)local e=""if nil==n then
return false
end
r=r or DEFAULT_KEY_VALUE_CONN_SYMBOL
l=l or DEFAULT_KWARG_ENTRY_CONN_SYMBOL
e=o.concat(n," ")if nil~=t and#keys(t)>0 then
local n=" "for t,e in a(t)do
if e~=nil then
n=n..i.format("%s%s%s%s",t,r,e,l)end
end
n=i.sub(n,1,#n-#l)e=e..n
end
if c~=nil then
e=e.." "e=e..o.concat(c," ")end
return e
end
function ping(e,t,r)local l={"ping"}if e==nil then
return false
end
local n={e}local e={}e["-c"]=t
e["-s"]=r
local e=construct_cmd(l,e,n)return execute_cmd(e)end
