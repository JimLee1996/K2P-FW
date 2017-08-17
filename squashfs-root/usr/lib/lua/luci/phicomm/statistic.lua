local c={"h5","pc","app"}module("luci.phicomm.statistic",package.seeall)function get_device_type()local i=require("luci.http")local t=require("luci.http.protocol")local e
local l="app"e=i.jsondata()e=e or json.decode(i.get_raw_data()or"",t.urldecode)or{}local i=e._deviceType or"app";local e
for c,e in ipairs(c)do
if e==i then
l=e
end
end
if"app"==l then
return"3"elseif"h5"==l then
return"2"else
return"1"end
end
function login()local e
e=get_device_type()luci.util.exec(string.format("statistics login %s >/dev/null; ",e))return E_NONE
end
function first_config()local l
local e=require("luci.model.uci")local e=e.cursor()l=get_device_type()e:set("luci","main","first_config",l)e:save("luci")e:commit("luci")return E_NONE
end
