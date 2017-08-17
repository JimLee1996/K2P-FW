module("luci.controller.admin.guest",package.seeall)function index()entry({"pc","guest.htm"},template("pc/guest")).leaf=true
entry({"h5","guest.htm"},template("h5/guest")).leaf=true
register_keyword_data("wireless","guest_wifi","get_guest_wifi_conf")end
function get_guest_wifi_conf(e)local r=require("luci.phicomm.error")local e=require("luci.model.uci")local t=e.cursor()local e,l
local i="rax1"t:foreach("wireless","wifi-iface",function(l)if(l.ifname==i)then
e=l
return
end
end)if e~=nil then
l={ssid=e.ssid or"",password=e.key or""}end
local e=e.disabled
local i={["0"]="1",["1"]="0"}l.enable=i[e]return r.E_NONE,l
end
