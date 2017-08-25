local i=require("luci.phicomm.error")
local e=require("luci.controller.ds")
local a=e.filter_key.validator

module("luci.data.adbset",package.seeall)

function index()
register_secname_cb("adbset","config","check_adbset_config","apply_adbset_config")
end

function check_adbset_config(t,c,l,t,t,t)
return i.E_NONE
end

function apply_adbset_config(e,e,e,l,e,e)

 if l.sip then
  nixio.fs.writefile("/etc/adbyby_sip.txt", l.sip:gsub("\r\n", "\n"))
 end

 if l.dip then
  nixio.fs.writefile("/etc/adbyby_dip.txt", l.dip:gsub("\r\n", "\n"))
 end

 if l.httpsip then
  nixio.fs.writefile("/etc/adbyby_httpsip.txt", l.httpsip:gsub("\r\n", "\n"))
 end

 if l.user then
  nixio.fs.writefile("/etc/adbyby_user.txt", l.user:gsub("\r\n", "\n"))
 end


return i.E_NONE,{wait_time=1}
end


