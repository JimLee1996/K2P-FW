local t=require("luci.phicomm.error")module("luci.controller.admin.auto_upgrade",package.seeall)function index()entry({"pc","sysUpgrade.htm"},template("pc/sysUpgrade")).leaf=true
entry({"h5","sysUpgrade.htm"},template("h5/sysUpgrade")).leaf=true
register_keyword_data("system","upgrade","get_upgrade_config")register_keyword_data("system","upgrade_info","do_online_upgrade")end
function do_online_upgrade(e)local e=e.action
if"start"==e or"get"==e then
return get_upgrade_info()elseif"upgrade_status"==e then
return get_upgrade_status()elseif"upgrade"==e then
return auto_system_upgrade()else
return t.E_INVARG
end
end
function get_upgrade_info()local e={}require("ubus")local r=ubus.connect()e.running_status="1"local n=""n=r:call("http","check_upgrade",{})e.running_status="2"local r=require("luci.model.uci")local r=r.cursor()e.sw_ver=r:get("system","system","fw_ver")local n=r:get("onekeyupgrade","config","retState")if n=="0"then
e.status_code="8802"return t.E_NONE,e
end
local n=r:get("onekeyupgrade","config","ErrorCode")if n~="0"then
e.status_code=n
return t.E_NONE,e
end
local n=r:get("onekeyupgrade","config","VerNum")if n=="0"then
e.status_code="0"return t.E_NONE,e
elseif n=="1"then
e.status_code="1"end
e.new_ver=r:get("onekeyupgrade","config","newversion")e.release_time=r:get("onekeyupgrade","config","reledate")local r=io.open("/tmp/verdesc","r")local n=r:read("*a")r:close()e.release_log=n
return t.E_NONE,e
end
function get_upgrade_config()local e=require("luci.model.uci")local r=e.cursor()local e={}e.mode=r:get("system","upgrade","mode")e.start_hour=r:get("system","upgrade","start_hour")e.start_minute=r:get("system","upgrade","start_minute")return t.E_NONE,e
end
function WIFEXITED(e)if e<=0 then
return e
end
local t=require"nixio".bit
return t.rshift(e,8)end
function auto_system_upgrade()local e="do_upgrade &"local e=WIFEXITED(os.execute(e))return t.E_NONE
end
function get_upgrade_status()local e="/tmp/up_code"local e=io.open(e,"r")local r
if e then
r=e:read()e:close()end
local e={}if r then
local t
for t in string.gmatch(r,"%d+")do
table.insert(e,t)end
end
local r={running_status=0,status_code=0,process_num=0}r.running_status=e[1]r.status_code=e[2]r.process_num=e[3]return t.E_NONE,r
end
