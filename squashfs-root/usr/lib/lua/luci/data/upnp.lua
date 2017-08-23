local l=require("luci.phicomm.error")local e=require("luci.controller.ds")local n=e.filter_key.validator
local c=e.filter_key.args
module("luci.data.upnp",package.seeall)function index()register_secname_cb("upnp","config","check_upnp_config","apply_upnp_config")end
function check_upnp_config(i,r,c,i,i,i)e.register_secname_filter(r,c,{enable={[n]="luci.phicomm.validator.check_bool"}})return l.E_NONE
end
function apply_upnp_config(e,e,e,c,e,e)local e=require("luci.model.uci")local e=e.cursor()e:set("UPnP","config","enable",c.enable)e:save("UPnP")e:apply("UPnP",false,true)return l.E_NONE
end
