local e=require("luci.phicomm.error")

module("luci.controller.admin.adb",package.seeall)

function index()
entry({"pc","adb.htm"},template("pc/adb")).leaf=true
entry({"h5","adb.htm"},template("h5/adb")).leaf=true
register_keyword_data("adb","config","get_adb_config")
end

function get_adb_config()
local l=require("luci.model.uci").cursor()
local re={enable=l:get("adbyby","adbyby","enable"),mode=l:get("adbyby","adbyby","mode"),runmode=l:get("adbyby","adbyby","runmode"),https=l:get("adbyby","adbyby","https")}
return e.E_NONE,re
end


