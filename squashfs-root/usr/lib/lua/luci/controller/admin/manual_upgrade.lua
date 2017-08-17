local e=require("luci.phicomm.error")module("luci.controller.admin.manual_upgrade",package.seeall)function index()entry({"pc","manualUpgrade.htm"},template("pc/manualUpgrade")).leaf=true
entry({"system","upgrade"},call("system_upgrade")).leaf=true
register_keyword_data("system","upgrade_status","get_upgrade_status")end
function WIFEXITED(e)if e<=0 then
return e
end
local n=require"nixio".bit
return n.rshift(e,8)end
function write_response(l)local t=require("luci.http")local n={}n[e.ERR_CODE]=l
n["module"]={}t.prepare_content("text/html")t.write_json(n)t.close()end
function system_upgrade()local l=require("luci.fs")local n=require("luci.http")local t="/tmp/sysupgrade.bin"local r=16*1024*1024
local i=tonumber(n.getenv("CONTENT_LENGTH"))or 0
if i>r then
n.setfilehandler(function(e,e,e)end)n.formvalue("filename")l.unlink(t)write_response(e.E_INVUPFILE)return e.E_INVUPFILE
end
local a=false
local o=false
local r=false
if n.getenv("PHIAPP_REQUEST")then
a=true
if n.getenv("CONTENT_TYPE")=="application/json"then
r=true
else
o=true
end
end
if not r then
local e
n.setfilehandler(function(r,n,l)if not e then
e=io.open(t,"w")end
if n then
e:write(n)end
if l then
e:close()end
end)n.formvalue("filename")end
local n="/tmp/up_code"local l=io.open(n,"r")local n
if l then
n=l:read()l:close()local t={}if n then
local e
for e in string.gmatch(n,"%d+")do
table.insert(t,e)end
end
if t[1]~='0'then
write_response(e.E_UPGRADE_UNDERWAY)return e.E_UPGRADE_UNDERWAY
end
end
local n="manual_upgrade "if a then
if o then
if i>0 then
n=n.."-c "..t
else
os.remove(t)write_response(e.E_DOWNFAIL_FAIL)return e.E_DOWNFAIL_FAIL
end
elseif r then
local l=io.open(t,"rb")if l then
l:close()n=n.."-u "..t
else
write_response(e.E_NOEXISTFILE)return e.E_DOWNFAIL_FAIL
end
end
local e=WIFEXITED(os.execute(n))write_response(e)else
n=n.."-u "..t.." &"os.execute(n)write_response(e.E_NONE)end
return e.E_NONE
end
function get_upgrade_status()local n="/tmp/up_code"local n=io.open(n,"r")local t
if n then
t=n:read()n:close()end
local n={}if t then
local e
for e in string.gmatch(t,"%d+")do
table.insert(n,e)end
end
local t={running_status=0,status_code=0,process_num=0}t.running_status=n[1]t.status_code=n[2]t.process_num=n[3]return e.E_NONE,t
end
