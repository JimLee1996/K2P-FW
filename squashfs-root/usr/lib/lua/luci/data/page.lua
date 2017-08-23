local e=require("luci.phicomm.error")local t=require("luci.controller.ds")local r=require("luci.phicomm.validator")local o=t.filter_key.validator
module("luci.data.page",package.seeall)function index()register_secname_cb("time_reboot","config","check_time_reboot","apply_time_reboot")end
function check_time_reboot(n,i,r,n,n,n)t.register_secname_filter(i,r,{enable={[o]="luci.phicomm.validator.check_bool"},reboot_hour={[o]="luci.data.page.check_reboot_hour"},reboot_minute={[o]="luci.data.page.check_reboot_minute"}})return e.E_NONE
end
function apply_time_reboot(o,o,o,t,o,o)local o=require("luci.model.uci")local o=o.cursor()o:set("timereboot","timereboot","enable",t.enable)if t.enable=="1"then
o:set("timereboot","timereboot","hour",t.reboot_hour)o:set("timereboot","timereboot","minute",t.reboot_minute)end
o:save("timereboot")o:commit("timereboot")os.execute("/usr/sbin/timereboot &")return e.E_NONE
end
function check_reboot_hour(o,t,t,t)if not r.check_num_range(o,0,23)then
return e.E_TIMERREBOOT_HOUR
end
return e.E_NONE
end
function check_reboot_minute(o,t,t,t)if not r.check_num(o)then
return e.E_TIMERREBOOT_MINUTE
end
local o=tonumber(o)local t
for t=0,55,5 do
if o==t then
return e.E_NONE
end
end
return e.E_TIMERREBOOT_MINUTE
end
