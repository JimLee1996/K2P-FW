local i=require"nixio.fs"local e=require"luci.sys"local e=require"luci.init"local r=require"luci.util"local l=require"luci.http"local d=require"nixio",require"nixio.util"local f=require("luci.json")local t=require("luci.controller.ds")local n=require("luci.phicomm.error")local e=require("luci.phicomm.util")local s=require("luci.phicomm.validator")local c=require"luci.sauth"local e=require("luci.fs")module("luci.dispatcher",package.seeall)context=r.threadlocal()_M.fs=i
authenticator={}local a=nil
local u
K_MODULE=t.KEY_MODULE
function tpl_get_data(e,n)local e=t.get_data(e)if n then
e=f.encode(e)end
return e
end
local e=nil
CFG_SEC_SEP=":"function create_dataindex()if dataindexcache then
local t=i.stat(dataindexcache,"mtime")if t then
local t=loadfile(dataindexcache)if type(t)=="function"then
e=t()if e~=nil then
return e
end
end
end
end
local t=luci.util.libpath().."/data/"local o={".lua",".lua.gz"}local n={}for r,o in ipairs(o)do
d.util.consume((i.glob(t.."*"..o)),n)d.util.consume((i.glob(t.."*/*"..o)),n)end
e={}for r,n in ipairs(n)do
local t="luci.data."..n:sub(#t+1,#n):gsub("/",".")for n,e in ipairs(o)do
t=t:gsub(e.."$","")end
local o=require(t)assert(o~=true,"Invalid dataer file found\n".."The file '"..n.."' contains an invalid module line.\n".."Please verify whether the module name is set to '"..t.."' - It must correspond to the file path!")local o=o.index
assert(type(o)=="function","Invalid dataer file found\n".."The file '"..n.."' contains no index() function.\n".."Please make sure that the controller contains a valid ".."index function and verify the spelling!")e[t]=o
end
if dataindexcache then
local t=d.open(dataindexcache,"w",600)t:writeall(r.get_bytecode(e))t:close()end
end
function create_datacbs()if not e then
create_dataindex()end
local t=context
t.datacbs={}local t=setmetatable({},{__index=luci.dispatcher})for n,e in pairs(e)do
t._NAME=n
setfenv(e,t)e()end
return datacbs
end
function dataentry(e,t,o,r)local t=e..CFG_SEC_SEP..t
local n=getfenv(2)._NAME
local e=context.datacbs[t]or{["chkfunc"]={},["srvfunc"]={}}if o~=nil then
e.chkfunc[n]=o
end
if r~=nil then
e.srvfunc[n]=r
end
context.datacbs[t]=e
return e
end
function cbentry(t,l,r,o,n)if type(t)~="string"or type(l)~="string"then
return nil
end
context.datacbs=context.datacbs or{}local a=context.datacbs[t]or{}local e=a[l]or{["chkfunc"]={},["srvfunc"]={}}a[l]=e
context.datacbs[t]=a
local t=getfenv(3)._NAME
if r~=nil then
if n~=nil then
e.chkfunc[n]={module=t,func=r}else
table.insert(e.chkfunc,{module=t,func=r})end
end
if o~=nil then
if n~=nil then
e.srvfunc[n]={module=t,func=o}else
table.insert(e.srvfunc,{module=t,func=o})end
end
return e
end
function register_secname_cb(t,e,o,r,n)return cbentry(t,e,o,r,n)end
register_secname_filter=t.register_secname_filter
register_keyword_data=t.register_keyword_data
register_keyword_set_data=t.register_keyword_set_data
register_module=t.register_module
function build_url(...)local n={...}local e={l.getenv("SCRIPT_NAME")or""}local t,t
for n,t in pairs(context.urltoken)do
e[#e+1]="/"e[#e+1]=l.urlencode(n)e[#e+1]="="e[#e+1]=l.urlencode(t)end
local t
for n,t in ipairs(n)do
if t:match("^[a-zA-Z0-9_%-%.%%/,;]+$")then
e[#e+1]="/"e[#e+1]=t
end
end
return table.concat(e,"")end
function node_visible(e)if e then
return not((not e.title or#e.title==0)or(not e.target or e.hidden==true)or(type(e.target)=="table"and e.target.type=="firstchild"and(type(e.nodes)~="table"or not next(e.nodes))))end
return false
end
function node_childs(e)local t={}if e then
local n,n
for n,e in r.spairs(e.nodes,function(n,t)return(e.nodes[n].order or 100)<(e.nodes[t].order or 100)end)do
if node_visible(e)then
t[#t+1]=n
end
end
end
return t
end
function error404(e)luci.http.status(404,"Not Found")e=e or"Not Found"require("luci.template")if not luci.util.copcall(luci.template.render,"error404")then
luci.http.prepare_content("text/plain")luci.http.write(e)end
return false
end
function error500(e)luci.util.perror(e)if not context.template_header_sent then
luci.http.status(500,"Internal Server Error")luci.http.prepare_content("text/plain")luci.http.write(e)else
require("luci.template")if not luci.util.copcall(luci.template.render,"error500",{message=e})then
luci.http.prepare_content("text/plain")luci.http.write(e)end
end
return false
end
function write_json(e)l.prepare_content("application/json")l.write_json(e,urlencode)end
function write_unauth(t)local e={}e[n.ERR_CODE]=t
write_json(e)return false
end
function authenticator.htmlauth(e,e,e)local e=(l.getenv("PATH_INFO")or""):gsub("^[/]*","")local t=l.getenv("REQUEST_METHOD"):upper()if""==e and"GET"==t then
luci.template.render("index")return false
end
if""~=e then
local e=require("luci.data.guide")local e=e.get_account()local e=e.mtime
if nil==e or""==e then
return write_unauth(n.E_SYSRESET)else
return write_unauth(n.E_UNAUTH)end
else
local t=require("luci.http.protocol")local e=l.jsondata()e=e or f.decode(l.get_raw_data()or"",t.urldecode)or{}if"set"==e.method then
if"table"==type(e.module)and"table"==type(e.module.security)then
local e=e.module.security
if"table"==type(e.login)then
local e=action_login(e.login)if not e then
return write_unauth(n.E_UNAUTH)end
return e
end
if"table"==type(e.logout)then
action_logout(e.logout)return false
end
if"table"==type(e.register)then
action_registe(e.register)return false
end
if"table"==type(e.modify)then
action_modify(e.modify)return false
end
return write_unauth(n.E_UNAUTH)else
return write_unauth(n.E_UNAUTH)end
else
return write_unauth(n.E_UNAUTH)end
end
return false
end
function action_login(e)local t="admin"local t=e.password
local n=require("luci.phicomm.statistic")if"string"==type(t)then
local e=require("luci.data.guide")local e=e.get_account()if t==e.pwd then
n.login()return e.user
end
end
return false
end
function action_logout(e)local o=require("luci.sauth")local r=e.stok or""local t=(l.getenv("REMOTE_ADDR")or"x.x.x.x"):gsub("%.","_")local e=o.read(t)if e and e.token==r then
o.kill(t)return write_unauth(n.E_NONE)end
return write_unauth(n.E_UNAUTH)end
function action_registe(e)local t=e.password
if"string"==type(t)then
local r=require("luci.data.guide")local e=r.get_account()local o=e.user
local l=e.pwd
local e=e.mtime
local l=require("luci.controller.admin.device")local a,l=l.get_welcome_config()if nil~=e and""~=e then
return write_unauth(n.E_HASINITPWD)end
local e=require"luci.base64"local e=e.decode(t)local e=s.check_passwd(e)if n.E_NONE~=e then
return write_unauth(e)end
r.set_account(o,t)local e=luci.sys.uniqueid(16)local t=luci.http.getenv("REMOTE_ADDR")or"x.x.x.x"local r=t:gsub("%.","_")c.write(r,{user=o,token=e})local e={[K_MODULE]={security={register={stok=e,ip=t,guide=l.guide}}},[n.ERR_CODE]=n.E_NONE}write_json(e)return o
end
return write_unauth(n.E_UNAUTH)end
function action_modify(e)local t=e.old_password
local e=e.new_password
if"string"==type(t)and"string"==type(e)then
local r=require("luci.data.guide")local o=r.get_account()local l=o.user
local a=o.pwd
local o=require"luci.base64"local o=o.decode(e)local o=s.check_passwd(o)if n.E_NONE~=o then
return write_unauth(o)end
if t==e then
return write_unauth(n.E_INLGVALOLDSAME)end
if a~=t then
return write_unauth(n.E_UNAUTH)end
r.modify_account(l,e)c.kill_all()write_unauth(n.E_NONE)return l
end
return write_unauth(n.E_UNAUTH)end
function httpdispatch(n,t)luci.http.context.request=n
local e={}context.request=e
context.urltoken={}local n=l.urldecode(n:getenv("PATH_INFO")or"",true)if t then
for n,t in ipairs(t)do
e[#e+1]=t
end
end
local o=true
for n in n:gmatch("[^/]+")do
local t,r
if o then
t,r=n:match("^(%w+)=([a-fA-F0-9]*)")end
if t then
context.urltoken[t]=r
else
o=false
e[#e+1]=n
end
end
local e,e=r.coxpcall(function()dispatch(context.request)end,error500)luci.http.close()end
function dispatch(a)local t=context
t.path=a
local e=require"luci.config"assert(e.main,"/etc/config/luci seems to be corrupt, unable to find section 'main'")if not t.datacbs then
create_datacbs()end
local e=t.tree
local o
if not e then
e=createtree()end
local o={}local c={}t.args=c
t.requestargs=t.requestargs or c
local s
local d=t.urltoken
local u={}local d={}for n,t in ipairs(a)do
u[#u+1]=t
d[#d+1]=t
e=e.nodes[t]s=n
if not e then
break
end
r.update(o,e)if e.leaf then
break
end
end
if e and e.leaf then
for e=s+1,#a do
c[#c+1]=a[e]d[#d+1]=a[e]end
end
t.requestpath=t.requestpath or d
t.path=u
if(e and e.index)or not o.notemplate then
local n=require("luci.template")local o=o.mediaurlbase or luci.config.main.mediaurlbase
local function l(t,e,o)if t then
local t=getfenv(3)local n=(type(t.self)=="table")and t.self
return string.format(' %s="%s"',tostring(e),luci.util.pcdata(tostring(o
or(type(t[e])~="function"and t[e])or(n and type(n[e])~="function"and n[e])or"")))else
return''end
end
n.context.viewns=setmetatable({write=luci.http.write;include=function(e)n.Template(e):render(getfenv(2))end;export=function(e,t)if n.context.viewns[e]==nil then n.context.viewns[e]=t end end;striptags=r.striptags;pcdata=r.pcdata;media=o;theme=i.basename(o);resource=luci.config.main.resourcebase;ifattr=function(...)return l(...)end;attr=function(...)return l(true,...)end;},{__index=function(n,e)if e=="controller"then
return build_url()elseif e=="REQUEST_URI"then
return build_url(unpack(t.requestpath))else
return rawget(n,e)or _G[e]end
end})end
o.dependent=(o.dependent~=false)assert(not o.dependent or not o.auto,"Access Violation\nThe page at '"..table.concat(a,"/").."/' ".."has no parent node so the access to this location has been denied.\n".."This is a software bug, please report this message at ".."http://luci.subsignal.org/trac/newticket")if o.sysauth then
local c=require"luci.sauth"local i=type(o.sysauth_authenticator)=="function"and o.sysauth_authenticator
or authenticator[o.sysauth_authenticator]local s=(type(o.sysauth)=="string")and o.sysauth
local d=s and{o.sysauth}or o.sysauth
local u=t.authsession
local o=false
if not u then
u=t.urltoken.stok
o=true
end
local h=luci.http.getenv("REMOTE_ADDR")or"x.x.x.x"local f=h:gsub("%.","_")local e=c.read(f)local a
if e then
if not o or t.urltoken.stok==e.token then
a=e.user
end
else
local e=l.getenv("HTTP_AUTH_USER")local t=l.getenv("HTTP_AUTH_PASS")if e and t and luci.sys.user.checkpasswd(e,t)then
i=function()return e end
end
end
if not r.contains(d,a)then
if i then
t.urltoken.stok=nil
local o,l=i(luci.sys.user.checkpasswd,d,s)if not o or not r.contains(d,o)then
return
else
local e=e and e.token or luci.sys.uniqueid(16)if not l then
c.reap()c.write(f,{user=o,token=e})t.urltoken.stok=e
end
t.authsession=e
t.authuser=o
local t=require("luci.controller.admin.device")local o,t=t.get_welcome_config()local t=t.guide
local e={[K_MODULE]={security={login={stok=e,ip=h,guide=t}}},[n.ERR_CODE]=n.E_NONE}write_json(e)return
end
else
luci.http.status(403,"Forbidden")return
end
else
t.authsession=u
t.authuser=a
end
end
if o.setgroup then
luci.sys.process.setgroup(o.setgroup)end
if o.setuser then
luci.sys.process.setuser(o.setuser)end
local n=nil
if e then
if type(e.target)=="function"then
n=e.target
elseif type(e.target)=="table"then
n=e.target.target
end
end
if e and(e.index or type(n)=="function")then
t.dispatched=e
t.requested=t.requested or t.dispatched
end
if e and e.index then
local e=require"luci.template"if r.copcall(e.render,"indexer",{})then
return true
end
end
if type(n)=="function"then
r.copcall(function()local o=getfenv(n)local t=require(e.module)local e=setmetatable({},{__index=function(n,e)return rawget(n,e)or t[e]or o[e]end})setfenv(n,e)end)local o,t
if type(e.target)=="table"then
o,t=r.copcall(n,e.target,unpack(c))else
o,t=r.copcall(n,unpack(c))end
assert(o,"Failed to execute "..(type(e.target)=="function"and"function"or e.target.type or"unknown").." dispatcher target for entry '/"..table.concat(a,"/").."'.\n".."The called action terminated with an exception:\n"..tostring(t or"(unknown)"))else
local e=node()if not e or not e.target then
error404("No root node was registered, this usually happens if no module was installed.\n".."Install luci-mod-base and retry. ".."If the module is already installed, try removing the /tmp/luci-indexcache file.")else
luci.http.redirect(luci.http.getenv("SCRIPT_NAME"))end
end
end
function createindex()local e=luci.util.libpath().."/controller/"local t={".lua",".lua.gz"}if luci.util.copcall(require,"luci.fastindex")then
createindex_fastindex(e,t)else
createindex_plain(e,t)end
end
function createindex_fastindex(t,e)a={}if not u then
u=luci.fastindex.new("index")for n,e in ipairs(e)do
u.add(t.."*"..e)u.add(t.."*/*"..e)end
end
u.scan()for t,e in pairs(u.indexes)do
a[e[2]]=e[1]end
end
function createindex_plain(n,o)if indexcache then
local e=i.stat(indexcache,"mtime")if e then
local e=loadfile(indexcache)if type(e)=="function"then
a=e()if a~=nil then
return a
end
end
end
end
local e={}for o,t in ipairs(o)do
d.util.consume((i.glob(n.."*"..t)),e)d.util.consume((i.glob(n.."*/*"..t)),e)end
a={}for e,t in ipairs(e)do
local e="luci.controller."..t:sub(#n+1,#t):gsub("/",".")for n,t in ipairs(o)do
e=e:gsub(t.."$","")end
local n=require(e)assert(n~=true,"Invalid controller file found\n".."The file '"..t.."' contains an invalid module line.\n".."Please verify whether the module name is set to '"..e.."' - It must correspond to the file path!")local n=n.index
assert(type(n)=="function","Invalid controller file found\n".."The file '"..t.."' contains no index() function.\n".."Please make sure that the controller contains a valid ".."index function and verify the spelling!")a[e]=n
end
if indexcache then
local e=d.open(indexcache,"w",600)e:writeall(r.get_bytecode(a))e:close()end
end
function createtree()if not a then
createindex()end
local e=context
local n={nodes={},inreq=true}local t={}e.treecache=setmetatable({},{__mode="v"})e.tree=n
e.modifiers=t
local e=setmetatable({},{__index=luci.dispatcher})for n,t in pairs(a)do
e._NAME=n
setfenv(t,e)t()end
local function o(n,e)return t[n].order<t[e].order
end
for n,t in r.spairs(t,o)do
e._NAME=t.module
setfenv(t.func,e)t.func()end
return n
end
function modifier(e,t)context.modifiers[#context.modifiers+1]={func=e,order=t or 0,module=getfenv(2)._NAME}end
function assign(e,t,n,o)local e=node(unpack(e))e.nodes=nil
e.module=nil
e.title=n
e.order=o
setmetatable(e,{__index=_create_node(t)})return e
end
function entry(e,t,o,n)local e=node(unpack(e))e.target=t
e.title=o
e.order=n
e.module=getfenv(2)._NAME
return e
end
function get(...)return _create_node({...})end
function node(...)local e=_create_node({...})e.module=getfenv(2)._NAME
e.auto=nil
return e
end
function _create_node(t)if#t==0 then
return context.tree
end
local o=table.concat(t,".")local e=context.treecache[o]if not e then
local n=table.remove(t)local r=_create_node(t)e={nodes={},auto=true}if r.inreq and context.path[#t+1]==n then
e.inreq=true
end
r.nodes[n]=e
context.treecache[o]=e
end
return e
end
function _firstchild()local n={unpack(context.path)}local e=table.concat(n,".")local t=context.treecache[e]local e
if t and t.nodes and next(t.nodes)then
local n,n
for o,n in pairs(t.nodes)do
if not e or(n.order or 100)<(t.nodes[e].order or 100)then
e=o
end
end
end
assert(e~=nil,"The requested node contains no childs, unable to redispatch")n[#n+1]=e
dispatch(n)end
function firstchild()return{type="firstchild",target=_firstchild}end
function alias(...)local e={...}return function(...)for n,t in ipairs({...})do
e[#e+1]=t
end
dispatch(e)end
end
function rewrite(n,...)local t={...}return function(...)local e=r.clone(context.dispatched)for t=1,n do
table.remove(e,1)end
for t,n in ipairs(t)do
table.insert(e,t,n)end
for n,t in ipairs({...})do
e[#e+1]=t
end
dispatch(e)end
end
local function n(t,...)local e=getfenv()[t.name]assert(e~=nil,'Cannot resolve function "'..t.name..'". Is it misspelled or local?')assert(type(e)=="function",'The symbol "'..t.name..'" does not refer to a function but data '..'of type "'..type(e)..'".')if#t.argv>0 then
return e(unpack(t.argv),...)else
return e(...)end
end
function call(e,...)return{type="call",argv={...},name=e,target=n}end
local e=function(e,...)require"luci.template".render(e.view)end
function template(t)return{type="template",view=t,target=e}end
local function d(e,...)local o=require"luci.cbi"local c=require"luci.template"local n=require"luci.http"local t=e.config or{}local o=o.load(e.model,...)local e=nil
for o,n in ipairs(o)do
n.flow=t
local t=n:parse()if t and(not e or t<e)then
e=t
end
end
local function r(e)return type(e)=="table"and build_url(unpack(e))or e
end
if t.on_valid_to and e and e>0 and e<2 then
n.redirect(r(t.on_valid_to))return
end
if t.on_changed_to and e and e>1 then
n.redirect(r(t.on_changed_to))return
end
if t.on_success_to and e and e>0 then
n.redirect(r(t.on_success_to))return
end
if t.state_handler then
if not t.state_handler(e,o)then
return
end
end
n.header("X-CBI-State",e or 0)if not t.noheader then
c.render("cbi/header",{state=e})end
local r
local n
local i=false
local l=true
local a={}for t,e in ipairs(o)do
if e.apply_needed and e.parsechain then
local t
for t,e in ipairs(e.parsechain)do
a[#a+1]=e
end
i=true
end
if e.redirect then
r=r or e.redirect
end
if e.pageaction==false then
l=false
end
if e.message then
n=n or{}n[#n+1]=e.message
end
end
for t,e in ipairs(o)do
e:render({firstmap=(t==1),applymap=i,redirect=r,messages=n,pageaction=l,parsechain=a})end
if not t.nofooter then
c.render("cbi/footer",{flow=t,pageaction=l,redirect=r,state=e,autoapply=t.autoapply})end
end
function cbi(e,t)return{type="cbi",config=t,model=e,target=d}end
local function o(e,...)local t={...}local n=#t>0 and e.targets[2]or e.targets[1]setfenv(n.target,e.env)n:target(unpack(t))end
function arcombine(t,e)return{type="arcombine",env=getfenv(),target=o,targets={t,e}}end
local function r(e,...)local t=require"luci.cbi"local o=require"luci.template"local r=require"luci.http"local n=luci.cbi.load(e.model,...)local e=nil
for n,t in ipairs(n)do
local t=t:parse()if t and(not e or t<e)then
e=t
end
end
r.header("X-CBI-State",e or 0)o.render("header")for t,e in ipairs(n)do
e:render()end
o.render("footer")end
function form(e)return{type="cbi",model=e,target=r}end
function _(e)return e
end
