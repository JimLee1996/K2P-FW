local i=require("luci.phicomm.error")local e=require("luci.controller.ds")local a=e.filter_key.validator
module("luci.data.light",package.seeall)function index()register_secname_cb("light","config","check_light_config","apply_light_config")end
function check_light_config(t,c,l,t,t,t)e.register_secname_filter(c,l,{enable={[a]="luci.phicomm.validator.check_bool"}})return i.E_NONE
end
function apply_light_config(e,e,e,l,e,e)local e=require("luci.model.uci").cursor()e:set("light_manage","pagelight","ignore",l.enable)e:save("light_manage")e:commit("light_manage")return i.E_NONE,{wait_time=2}end
