local n=require("luci.phicomm.error")module("luci.controller.admin.lan",package.seeall)function index()entry({"pc","lanSet.htm"},template("pc/lanSet")).leaf=true
entry({"h5","lanSet.htm"},template("h5/lanSet")).leaf=true
register_keyword_data("network","lan","get_lan_config")end
function get_lan_config(e)local e={}local l=require("luci.model.uci")local l=l.cursor()e.ip=l:get("network","lan","ipaddr")or"0.0.0.0"e.netmask=l:get("network","lan","netmask")or"0.0.0.0"e.mac=string.upper(l:get("network","lan","macaddr")or"00:00:00:00:00:00")return n.E_NONE,e
end
