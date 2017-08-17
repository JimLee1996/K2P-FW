local e=require("luci.phicomm.error")module("luci.controller.admin.light",package.seeall)function index()entry({"pc","light.htm"},template("pc/light")).leaf=true
entry({"h5","light.htm"},template("h5/light")).leaf=true
register_keyword_data("light","config","get_light_config")end
function get_light_config()local l=require("luci.model.uci").cursor()local l={enable=l:get("light_manage","pagelight","ignore")}return e.E_NONE,l
end
