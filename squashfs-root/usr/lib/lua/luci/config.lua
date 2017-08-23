local e=require"luci.util"module("luci.config",function(i)if pcall(require,"luci.model.uci")then
local l=e.threadlocal()setmetatable(i,{__index=function(i,e)if not l[e]then
l[e]=luci.model.uci.cursor():get_all("luci",e)end
return l[e]end})end
end)