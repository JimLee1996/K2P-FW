module("luci.http.protocol.date",package.seeall)require("luci.sys.zoneinfo")MONTHS={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}function tz_offset(t)if type(t)=="string"then
local n,e=t:match("([%+%-])([0-9]+)")if n=='+'then n=1 else n=-1 end
if e then e=tonumber(e)end
if n and e then
return n*60*(math.floor(e/100)*60+(e%100))elseif luci.sys.zoneinfo.OFFSET[t:lower()]then
return luci.sys.zoneinfo.OFFSET[t:lower()]end
end
return 0
end
function to_unix(e)local n,e,i,a,r,t,o,u=e:match("([A-Z][a-z][a-z]), ([0-9]+) ".."([A-Z][a-z][a-z]) ([0-9]+) ".."([0-9]+):([0-9]+):([0-9]+) ".."([A-Z0-9%+%-]+)")if e and i and a and r and t and o then
local n=1
for e=1,12 do
if MONTHS[e]==i then
n=e
break
end
end
return tz_offset(u)+os.time({year=a,month=n,day=e,hour=r,min=t,sec=o})end
return 0
end
function to_http(e)return os.date("%a, %d %b %Y %H:%M:%S GMT",e)end
function compare(n,e)if n:match("[^0-9]")then n=to_unix(n)end
if e:match("[^0-9]")then e=to_unix(e)end
if n==e then
return 0
elseif n<e then
return-1
else
return 1
end
end
