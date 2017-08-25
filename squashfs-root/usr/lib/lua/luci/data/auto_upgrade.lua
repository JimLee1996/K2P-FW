local a=require("luci.phicomm.error")local r=require("luci.controller.ds")local e=r.filter_key.validator
local t=r.filter_key.args
module("luci.data.auto_upgrade",package.seeall)function index()register_secname_cb("system","upgrade","check_upgrade","apply_upgrade")end
function check_num_range(t,e,e,e,u,r)local e=require("luci.phicomm.validator")if not e.check_num_range(t,u,r)then
return a.E_INVARG
end
return a.E_NONE
end
function check_upgrade(l,c,u,l,l,l)r.register_secname_filter(c,u,{mode={[e]="luci.phicomm.validator.check_bool"},start_hour={[e]="luci.data.auto_upgrade.check_num_range",[t]={0,23}},start_minute={[e]="luci.data.auto_upgrade.check_num_range",[t]={0,59}}})return a.E_NONE
end
function apply_upgrade(e,e,e,r,e,e)local e=require("luci.model.uci")local e=e.cursor()e:set("system","upgrade","mode",r.mode)if r.mode=="1"then
e:set("system","upgrade","start_hour",r.start_hour)e:set("system","upgrade","start_minute",r.start_minute)end
e:save("system")e:commit("system")os.execute("/usr/sbin/regular_check &")return a.E_NONE
end
