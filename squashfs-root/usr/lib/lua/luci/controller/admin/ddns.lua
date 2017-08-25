local e=require("luci.phicomm.error")module("luci.controller.admin.ddns",package.seeall)function index()entry({"pc","ddns.htm"},template("pc/ddns")).leaf=true
register_keyword_data("ddns","config","get_ddns_config")end
function get_ddns_config()local d=require("luci.model.uci").cursor()local d={enable=d:get("ddns","myddns","enabled")or"0",provider=d:get("ddns","myddns","service_name")or"",user=d:get("ddns","myddns","username")or"",password=d:get("ddns","myddns","password")or"",domain=d:get("ddns","myddns","domain")or""}return e.E_NONE,d
end
