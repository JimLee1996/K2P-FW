local l=require("luci.phicomm.error")module("luci.controller.admin.port_forward",package.seeall)function index()entry({"pc","portForwad.htm"},template("pc/portForwad")).leaf=true
register_keyword_data("port_forward","config","get_forward_config")register_keyword_data("port_forward","forward_list","get_forward_list")end
function get_forward_config()local r={}local o=require("luci.model.uci")local o=o.cursor()r.enable=o:get("appportfwd","config","enable")return l.E_NONE,r
end
function get_forward_list()local t={}local r=require("luci.model.uci")local r=r.cursor()local a={["tcp"]="1",["udp"]="2",["tcp+udp"]="3"}local o=require"luci.util"r:foreach("appportfwd","setting",function(r)local e=o.split(r.exterport,"-")local o=o.split(r.interport,"-")local r={id=r.id,name=r.name,ip=r.serverip,extern_port_start=e[1],extern_port_end=e[2]or e[1],inner_port_start=o[1],inner_port_end=o[2]or o[1],protocol=a[r.proto]}t[#t+1]=r
end)return l.E_NONE,t
end
