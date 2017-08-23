module("luci.sauth",package.seeall)require("luci.util")require("luci.sys")require("luci.config")local s=require"nixio",require"nixio.util"local e=require"nixio.fs"luci.config.sauth=luci.config.sauth or{}sessionpath=luci.config.sauth.sessionpath
sessiontime=tonumber(luci.config.sauth.sessiontime)or 15*60
function prepare()e.mkdir(sessionpath,700)if not sane()then
error("Security Exception: Session path is not sane!")end
end
local function t(n)local e=e.readfile(sessionpath.."/"..n)return e
end
local function o(i,t)local n=s.open(sessionpath.."/"..i,"w",600)n:writeall(t)n:close()local n=luci.sys.uptime()e.utimes(sessionpath.."/"..i,n,n)end
local function i(e)return not not(e and e:match("^[a-fA-F0-9_]+$"))end
function write(n,e)if not sane()then
prepare()end
assert(i(n),"Security Exception: Session ID is invalid!")assert(type(e)=="table","Security Exception: Session data invalid!")o(n,luci.util.get_bytecode(e))end
function read(n)if not n or#n==0 then
return nil
end
assert(i(n),"Security Exception: Session ID is invalid!")if not sane(sessionpath.."/"..n)then
return nil
end
local i=t(n)local i=loadstring(i)setfenv(i,{})local s=i()assert(type(s)=="table","Session data invalid!")local t=e.stat(sessionpath.."/"..n,"mtime")local i=luci.sys.uptime()if t+sessiontime<i then
kill(n)return nil
end
e.utimes(sessionpath.."/"..n,i,i)return s
end
function sane(n)return luci.sys.process.info("uid")==e.stat(n or sessionpath,"uid")and e.stat(n or sessionpath,"modestr")==(n and"rw-------"or"rwx------")end
function kill(n)if i(n)then e.unlink(sessionpath.."/"..n)end
end
function kill_all()if sane()then
local e
for e in s.fs.dir(sessionpath)do
kill(e)end
end
end
function clear_expired_session(n)if not n or#n==0 then
return nil
end
if not sane(sessionpath.."/"..n)then
return true
end
local i=t(n)local i=loadstring(i)setfenv(i,{})local i=i()if type(i)~="table"then
kill(n)return true
end
local i=e.stat(sessionpath.."/"..n,"mtime")local e=luci.sys.uptime()if i+sessiontime<e then
kill(n)return true
end
return true
end
function reap()if sane()then
local e
for e in s.fs.dir(sessionpath)do
if i(e)then
clear_expired_session(e)end
end
end
end
