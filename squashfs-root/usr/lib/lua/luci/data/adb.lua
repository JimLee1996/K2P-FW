local i=require("luci.phicomm.error")
local e=require("luci.controller.ds")
local a=e.filter_key.validator

module("luci.data.adb",package.seeall)

function index()
register_secname_cb("adb","config","check_adb_config","apply_adb_config")
end

function check_adb_config(t,c,l,t,t,t)
e.register_secname_filter(c,l,{enable={[a]="luci.phicomm.validator.check_bool"},mode={[a]="luci.phicomm.validator.check_bool"},runmode={[a]="luci.phicomm.validator.check_bool"},https={[a]="luci.phicomm.validator.check_bool"}})
return i.E_NONE
end

function apply_adb_config(e,e,e,l,e,e)
local e=require("luci.model.uci").cursor()
e:set("adbyby","adbyby","enable",l.enable)
e:set("adbyby","adbyby","mode",l.mode)
e:set("adbyby","adbyby","runmode",l.runmode)
e:set("adbyby","adbyby","https",l.https)
e:save("adbyby")
e:commit("adbyby")

if l.enable=="0" then
 luci.sys.call("/etc/init.d/adbyby disable")
 luci.sys.call("/etc/init.d/adbyby stop")
else
 luci.sys.call("/etc/init.d/adbyby enable")
 luci.sys.call("/etc/init.d/adbyby restart")
end

return i.E_NONE,{wait_time=5}
end

