local e=require("luci.phicomm.error")module("luci.controller.admin.backup_reset",package.seeall)function index()entry({"pc","backupReset.htm"},template("pc/backupReset")).leaf=true
entry({"system","backup_download"},call("download_conf")).leaf=true
entry({"system","backup_upload"},call("upload_conf")).leaf=true
end
function write_response(n)local l=require("luci.http")local c={}c[e.ERR_CODE]=n
l.prepare_content("text/html")l.write_json(c)l.close()end
function check_product_name()local e=require"luci.model.uci".cursor()local l=e:get("system","system","hostname")local e=luci.util.exec([[head /tmp/backupFile -n 10 | grep -m 1 "product" | awk -F= '{print$2}']])e=(string.sub(e,1,-2))if(l==e)then
return true
else
return false
end
end
function check_fwversion()local e=require"luci.model.uci".cursor()local l=e:get("system","system","fw_ver")or"0.0.0.0"local e=luci.util.exec([[head /tmp/backupFile -n 10 | grep -m 1 "fw_ver" | awk -F= '{print$2}']])local e="verrevcmp".." "..l.." "..e
local e=luci.util.exec(e)if tonumber(e)>0 then
return false
else
return true
end
end
function generate_backup_conf()local e=require"luci.util"e.exec("sh /sbin/backup_restore --create-backup /tmp/backup_pack 2>/dev/null")end
function reset_backup_conf()local l=require"luci.util"local n=require"nixio"luci.util.exec("encryconfig decrypt /tmp/backupFile_tmp /tmp/backupFile")local c=io.open("/tmp/backupFile",r)local l=e.E_NONE
if c~=nil then
local t=c:read()c:close()if t~=nil then
if not check_fwversion()then
l=e.E_INCONFILE
elseif not check_product_name()then
l=e.E_INCONFILE
else
luci.util.exec("sed 1,10d /tmp/backupFile >/tmp/restore_rm_header")luci.util.exec("tar -xzC/ -f /tmp/restore_rm_header")n.fs.unlink("/tmp/restore_rm_header")local l=""local e=require"luci.controller.admin.network"local c,e=e.get_wan_config()if e["clone_mode"]==0 then
l=e["source_mac"]else
l=e["mac"]end
local e=""local c=require"luci.controller.admin.lan"local n,c=c.get_lan_config()e=c["mac"]local c=luci.util.exec("eth_mac r lan")local n=luci.util.exec("eth_mac r wan")if e~=c then
luci.util.exec("uci set network.lan.macaddr=%s"%c)end
if l~=n then
luci.util.exec("uci set network.wan.macaddr=%s"%n)end
luci.util.exec("uci commit")end
else
l=e.E_INCONFILE
end
else
l=e.E_INCONFILE
end
return l
end
function download_conf()local t=require("luci.fs")local e=require("luci.http")local c="/tmp/backupFile"local l=1024
generate_backup_conf()e.header('Content-Disposition','attachment; filename = config.dat')e.prepare_content("application/octet-stream")local n=assert(io.open(c,"rb"))while true do
local l=n:read(l)if l==nil then
break
end
e.write(l)end
n:close()t.unlink(c)end
function upload_conf()local t=require("luci.fs")local l=require("luci.http")local n="/tmp/backupFile_tmp"local r=512*1024
local c=tonumber(l.getenv("CONTENT_LENGTH")or 0)if c>r then
l.setfilehandler(function(e,e,e)end)l.formvalue("filename")t.unlink(n)write_response(e.E_INCONFILE)return e.E_INCONFILE
end
local c
l.setfilehandler(function(t,e,l)if not c then
c=io.open(n,"w")end
if e then
c:write(e)end
if l then
c:close()end
end)l.formvalue("filename")local l=reset_backup_conf()write_response(l)t.unlink(n)if e.E_NONE==l then
os.execute("(sleep 1; reboot) &")end
return e.E_NONE
end
