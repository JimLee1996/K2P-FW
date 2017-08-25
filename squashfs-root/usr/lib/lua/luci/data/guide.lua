local l=require("luci.phicomm.error")local n=require("luci.controller.ds")local o=n.filter_key.validator
module("luci.data.guide",package.seeall)local e,c,i,a,r="luci","admin","username","password","mtime"function index()register_secname_cb("welcome","config","check_welcome_conf","apply_welcome_conf")end
function check_welcome_conf(i,c,e,i,i,i)n.register_secname_filter(c,e,{agreement={[o]="luci.phicomm.validator.check_bool"},language={[o]="luci.data.guide.check_lang"},guide={[o]="luci.phicomm.validator.check_bool"}})return l.E_NONE
end
function check_lang(e,c,c,c)local c={"auto","zh-cn","en-us"}if"string"~=type(e)then
return l.E_INVARG
end
local o
for o,c in ipairs(c)do
if c==e then
return l.E_NONE
end
end
return l.E_INVARG
end
function apply_welcome(o)local i="main"local c=require("luci.model.uci")local c=c.cursor()local n,n
for o,l in pairs(o)do
c:set(e,i,o,l)end
c:commit(e)return l.E_NONE
end
function apply_welcome_conf(c,c,c,c,e,c)return apply_welcome(e)end
function get_account()local l=require("luci.model.uci")local l=l.cursor()local e={user=l:get(e,c,i),pwd=l:get(e,c,a),mtime=l:get(e,c,r)}return e
end
function set_account(c,e)modify_account(c,e)local e=require("luci.phicomm.statistic")e.first_config()local e=require("luci.model.uci").cursor()e:delete("dhcp","welcome")e:save("dhcp")e:commit("dhcp")e:apply("dnsmasq")end
function modify_account(o,n)local l=require("luci.model.uci").cursor()local t=os.time()*1e3
l:set(e,c,a,n)l:set(e,c,i,o)l:set(e,c,r,t)l:commit(e)end
