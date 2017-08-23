local i=require("luci.phicomm.error")local s=require"io"module("luci.controller.admin.find_pppoe_pwd",package.seeall)function index()entry({"pc","checkRouterLink.htm"},template("pc/checkRouterLink")).leaf=true
entry({"pc","findPppoePwd.htm"},template("pc/findPppoePwd")).leaf=true
entry({"h5","checkRouterLink.htm"},template("h5/checkRouterLink")).leaf=true
entry({"h5","findPppoePwd.htm"},template("h5/findPppoePwd")).leaf=true
register_keyword_data("find_pwd","link_status","get_link_status")register_keyword_data("find_pwd","config","get_find_pwd_conf")end
function get_link_status()require("ubus")local e=ubus.connect()local e=e:call("rth.inet","get_port_link",{})local e=e["port_link"]local t="0"if e["port0"]=="up"or e["port1"]=="up"or e["port2"]=="up"or e["port3"]=="up"then
t="1"end
local e={status=t}return i.E_NONE,e
end
function get_find_pwd_conf()local r
local p=0
local l
local n,c,t,e
local o=require"luci.model.uci".cursor()luci.sys.call("/etc/init.d/pppoe-server start")nixio.fs.remove("/etc/pppoe-passwd")repeat
os.execute("sleep 2")p=p+1
l=nixio.fs.access("/etc/pppoe-passwd")until l or p==4
if l then
r=s.open("/etc/pppoe-passwd","r")n="1"c=r:read()or""t=r:read()or""e=r:read()or""r:close()if t and e then
t=string.sub(t,6,-1)e=string.sub(e,8,-1)o:set("network","wan","username",t)o:set("network","wan","password",e)o:save("network")o:commit("network")end
else
n="0"c=""t=""e=""end
local e={find_success=n,user=t,password=e}luci.sys.call("/etc/init.d/pppoe-server stop")return i.E_NONE,e
end
