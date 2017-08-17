local r=require("luci.phicomm.error")module("luci.controller.admin.dmz",package.seeall)function index()entry({"pc","dmz.htm"},template("pc/dmz")).leaf=true
register_keyword_data("firewall","dmz","get_dmz_config")end
function get_dmz_config(e)local e={}local l=require("luci.model.uci")local l=l.cursor()e.enable=l:get("DMZ","DMZ","enable")e.ip=l:get("DMZ","DMZ","dmz_ip")return r.E_NONE,e
end