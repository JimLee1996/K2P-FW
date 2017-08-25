local e=require("luci.phicomm.error")local i=require("luci.controller.ds")local o=i.filter_key.validator
module("luci.data.signal",package.seeall)function index()register_secname_cb("signal_set","config","check_signal_config","apply_signal_config")end
function check_signal_config(r,l,c,r,r,r)i.register_secname_filter(l,c,{power={[o]="luci.phicomm.validator.check_bool"}})return e.E_NONE
end
function apply_signal_config(c,c,c,c,i,c)local c=require("luci.model.uci").cursor()phicomm_lua=require("phic")if i.power~=nil then
phicomm_lua.set_wifi_device_config("2.4G","power",i.power)end
return e.E_NONE,{wait_time=40}end
