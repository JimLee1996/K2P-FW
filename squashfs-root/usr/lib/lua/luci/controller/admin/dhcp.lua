local e=require("luci.phicomm.error")module("luci.controller.admin.dhcp",package.seeall)function index()entry({"pc","dhcp.htm"},template("pc/dhcp")).leaf=true
register_keyword_data("dhcpd","config","get_dhcpd_config")register_keyword_data("dhcpd","bind_list","get_bind_list")end
function get_dhcpd_config(n)local n=require("luci.model.uci")local n=n.cursor()ipaddr=n:get("network","lan","ipaddr")ip3,ip2,ip1,ip0=string.match(ipaddr,"(%d+)%.(%d+)%.(%d+)%.(%d+)")ip_int=ip3*math.pow(256,3)+ip2*math.pow(256,2)+ip1*math.pow(256,1)+ip0
netmask=n:get("network","lan","netmask")nm3,nm2,nm1,nm0=string.match(netmask,"(%d+)%.(%d+)%.(%d+)%.(%d+)")nm_int=nm3*math.pow(256,3)+nm2*math.pow(256,2)+nm1*math.pow(256,1)+nm0
local t=require("nixio").bit
ip_and_nm=t.band(ip_int,nm_int)ip_nm3,ip_and_nm=math.modf(ip_and_nm/math.pow(256,3))ip_nm2,ip_and_nm=math.modf(ip_and_nm*256)ip_nm1,ip_and_nm=math.modf(ip_and_nm*256)ip_nm0,ip_and_nm=math.modf(ip_and_nm*256)num=0
while(nm_int>0)do
nm_int=nm_int-math.pow(2,31-num)num=num+1
end
ipaddr_table={tostring(ip_nm3),".",tostring(ip_nm2),".",tostring(ip_nm1),".",tostring(ip_nm0),"/",tostring(num)}ipaddr_range=table.concat(ipaddr_table)local t=n:get("dhcp","lan","start")local i=tonumber(t)+tonumber(n:get("dhcp","lan","limit"))-1
local n={enable=n:get("dhcp","lan","dynamicdhcp")or"1",pool_start=t,pool_end=tostring(i),network_address=ipaddr_range}return e.E_NONE,n
end
function get_bind_list()local n=require("luci.model.uci")local n=n.cursor()local t,a,i
n:foreach("dhcp","host",function(i)local e=n:get("network","lan","macaddr")if e~=i.mac then
t=t or{}a=string.gsub(i.mac,":","_")n:set_confdir("/var/state/")local e=n:get("base_device",a,"hostname")or"UnKnown"local d=n:get("base_device",a,"brand")or"UnKnown"n:set_confdir("/etc/config/")clients_name=n:get("common_host",a,"hostname")or e
local n={id=string.gsub(i.mac,":","_"),name=clients_name,ip=i.ip,brand=d,mac=i.mac}t[#t+1]=n
end
end)return e.E_NONE,t
end
