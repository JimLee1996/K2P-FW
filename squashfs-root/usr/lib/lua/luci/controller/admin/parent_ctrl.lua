local c=require("luci.phicomm.error")module("luci.controller.admin.parent_ctrl",package.seeall)function index()entry({"pc","parentCtrl.htm"},template("pc/parentCtrl")).leaf=true
entry({"pc","timePick.htm"},template("pc/timePick")).leaf=true
entry({"h5","parentCtrl.htm"},template("h5/parentCtrl")).leaf=true
entry({"h5","devList.htm"},template("h5/devList")).leaf=true
entry({"h5","parentCtrlAddRule.htm"},template("h5/parentCtrlAddRule")).leaf=true
entry({"h5","parentCtrlRule.htm"},template("h5/parentCtrlRule")).leaf=true
register_keyword_data("parent_ctrl","config","get_parent_config")register_keyword_data("parent_ctrl","parent_list","get_parent_list")end
function get_parent_config(e)local e={}local t=require("luci.model.uci")local t=t.cursor()e.enable=t:get("parentctl","config","enabled")return c.E_NONE,e
end
function get_parent_list()local a={}local e=require("luci.model.uci")local t=e.cursor()local r=require"luci.util"t:foreach("parentctl","rule",function(e)local l={0,0,0,0,0,0,0}local n=r.split(e.weekdays,",")for t,e in ipairs(n)do
l[tonumber(e)]="1"end
local n=""for e,t in ipairs(l)do
n=n..l[e]end
local l=r.split(e.start_time,":")local c=tonumber(l[1])*3600+tonumber(l[2])*60
local r=r.split(e.stop_time,":")local l=tonumber(r[1])*3600+tonumber(r[2])*60
local r=string.gsub(e.src_mac,":","_")t:set_confdir("/var/state/")local o=t:get("base_device",r,"hostname")or"UnKnown"local r=t:get("base_device",r,"brand")or"UnKnown"t:set_confdir("/etc/config/")local e={id=e.ruleindex,mac=e.src_mac,brand=r,name=t:get("common_host",string.gsub(e.src_mac,":","_"),"hostname")or o,cycle=n,start_time=c,end_time=l}a[#a+1]=e
end)return c.E_NONE,a
end
