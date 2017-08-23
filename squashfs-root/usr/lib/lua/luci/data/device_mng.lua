local n=require("luci.phicomm.error")local c=require("luci.controller.ds")local e=c.filter_key.validator
local i=c.filter_key.args
module("luci.data.device_mng",package.seeall)function index()register_secname_cb("device_manage","client_list","check_client","apply_client_config")end
function check_client(o,t,l,o,o,o)c.register_secname_filter(t,l,{mac={[e]="luci.phicomm.validator.check_mac"},ip={[e]="luci.phicomm.validator.check_ip"},name={[e]="luci.data.device_mng.check_name"},upload_limit={[e]="luci.data.device_mng.check_speed",[i]={0,4096}},download_limit={[e]="luci.data.device_mng.check_speed",[i]={0,4096}},internet_enable={[e]="luci.phicomm.validator.check_bool"}})return n.E_NONE
end
function check_name(e,c,c,c)if"string"~=type(e)then
return n.E_DEVMNG_RNM
end
if 0==#e or#e>32 then
return n.E_DEVMNG_RNM
end
return n.E_NONE
end
function check_speed(l,i,i,i,c,e)local i=require("luci.phicomm.validator")if not i.check_num_range(l,c,e)then
return n.E_DEVMNG_LMT
end
return n.E_NONE
end
function apply_client_config(o,c,c,e,c,c)if not e.mac then
return n.E_DEVMNG_EMAC
end
local a=e.mac
local c=require("luci.model.uci").cursor()local i=string.gsub(a,":","_")local l=e.name
local _=c:get("common_host",i,"hostname")or nil
local d=e.upload_limit or c:get("device_manage",i,"tx_rate")or"0"local r=e.download_limit or c:get("device_manage",i,"rx_rate")or"0"local t=c:get("device_manage",i,"block_user")or"0"if nil~=e.internet_enable then
if e.internet_enable=="0"or e.internet_enable==0 then
t="1"else
t="0"end
end
if"set"==o then
if nil~=l and _~=l then
if _ then
c:set("common_host",i,"hostname",l)else
c:section("common_host","host",i,{hostname=l})end
c:commit("common_host")end
elseif"del"==o then
t="0"d="0"r="0"end
if"del"==o or nil~=e.internet_enable or nil~=e.upload_limit or nil~=e.download_limit then
os.execute('device_manage_set mac "'..a..'" block_user "'..t..'" rx_rate "'..r..'" tx_rate "'..d..'" > /dev/console')end
return n.E_NONE
end
