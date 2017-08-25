local r=require("luci.http")local e=require("luci.phicomm.error")local d=require("luci.phicomm.util")module("luci.controller.ds",package.seeall)KEY_METHOD="method"KEY_MODULE="module"METHOD_ADD="add"METHOD_DELETE="del"METHOD_MODIFY="set"METHOD_GET="get"KEYWORD_FUNCPATH="funcpath"keyword_data_table={}keyword_set_data_table={}module_speclist={}function register_module(e)if type(e)~="table"then
return false
end
for e,n in pairs(e)do
if type(e)~="string"or type(n)~="table"then
return false
else
module_speclist[e]={}module_speclist[e]["depends"]=n
end
end
return true
end
FILTER_UCI_SEC_SEP=":"uci_secname_filters={}filter_key={need="need",validator="validator",args="args"}function register_secname_filter(e,n,t)if type(t)~="table"or type(e)~="string"or type(n)~="string"then
return false
end
uci_secname_filters[e..FILTER_UCI_SEC_SEP..n]=t
return true
end
function register_keyword_data(e,t,n)return register_keyword_datastruct(e,keyword_data_table,t,n)end
function register_keyword_set_data(n,t,e)return register_keyword_datastruct(n,keyword_set_data_table,t,e)end
function register_keyword_datastruct(n,e,t,l)if type(n)~="string"or type(t)~="string"or type(l)~="string"then
return false
end
e=e or{}local a=getfenv(3)._NAME
local r=e[n]or{}e[n]=r
local r=e[n][t]or{}e[n][t]=r
table.insert(r,{[KEYWORD_FUNCPATH]=a.."."..l})return true
end
function index()local e=node("data")e.target=firstchild()e.sysauth="admin"e.sysauth_authenticator="htmlauth"e.index=true
entry({"data","ds"},call("ds"),"DataService",20).index=true
end
function ds()local n={}local t=r.jsondata()if not t then
n[e.ERR_CODE]=e.E_INVFMT
write_json(n)return
end
local r=t[KEY_METHOD]local a={[METHOD_ADD]=set_data,[METHOD_DELETE]=set_data,[METHOD_MODIFY]=set_data,[METHOD_GET]=get_data}local l=t[KEY_MODULE]local t=a[r]if t then
n=t(l,r)else
n[e.ERR_CODE]=e.E_INVFMT
end
write_json(n)end
function set_data(r,l)local n=e.E_NONE
local n={}if type(r)~="table"and type(l)~="string"then
n[e.ERR_CODE]=e.E_INVFMT
return n
end
local t,i,a,o=get_diff_data(r,l)if t~=e.E_NONE then
n[e.ERR_CODE]=t
return n
end
t=do_chkcb(r,a,i,l)if t~=e.E_NONE then
n[e.ERR_CODE]=t
return n
end
t=filter_args(r,a,i)if t~=e.E_NONE then
n[e.ERR_CODE]=t
return n
end
t,extra=do_srvcb(r,a,i,l)if t~=e.E_NONE then
n[e.ERR_CODE]=t
return n
end
n[KEY_MODULE]=extra
n[e.ERR_CODE]=e.E_NONE
return n
end
function get_data(t)local n={}local i={}local o=nil
local r=false
if type(t)~="table"then
n[e.ERR_CODE]=e.E_INVFMT
return n
end
for d,t in pairs(t)do
local a={}local l=false
if"string"==type(t)then
t={t}elseif"table"~=type(t)then
n={}n[e.ERR_CODE]=e.E_INVFMT
return n
end
if"table"~=type(t)then
n={}n[e.ERR_CODE]=e.E_INVFMT
return n
end
for t,i in pairs(t)do
r,o=get_name_data(d,t,i)if e.E_NONE==r then
a[t]=o
l=true
else
n={}n[e.ERR_CODE]=r
return n
end
end
if not l then
n={}n[e.ERR_CODE]=e.E_INVFMT
return n
end
i[d]=a
end
n[KEY_MODULE]=i
n[e.ERR_CODE]=e.E_NONE
return n
end
function write_json(e)r.prepare_content("application/json")if r.getenv("PHIAPP_REQUEST")then
r.write_json(e,r.json_escape)else
r.write_json(e,r.urlencode)end
end
function do_keyword_func(_,a,t,n)if type(a)~="string"or type(t)~="table"then
return false
end
n=n or{}local t=t[_]or{}local r=t[a]local t={}if not r or"table"~=type(r)then
return false
end
for l,r in pairs(r)do
local r=r[KEYWORD_FUNCPATH]if not r then
return false
end
local o,i=d.split_module_func(r)local l=nil
if o~=nil then
l=require(o)end
local l=l and i and l[i]or nil
assert(l~=nil,'Cannot resolve function "'..r..'". Is it misspelled or local?')local r,n=l(n,_,a)if e.E_NONE~=r then
return true,r
elseif nil~=n then
if type(n)=="table"then
t=d.merge_table(t,n)elseif type(n)=="string"then
table.insert(t,n)end
end
end
return true,e.E_NONE,t
end
function get_name_data(n,t,r)if type(n)~="string"or type(t)~="string"then
return e.E_INVARG
end
local l=nil
local l=false
local l=e.E_NONE
local t,n,r=do_keyword_func(n,t,keyword_data_table,r)if t then
if type(n)~="number"then
return e.E_INVFMT
end
return n,r
else
return e.E_INVARG
end
end
function get_diff_data(i,a)local l,n,t,r=e.E_INVFMT,nil,nil,false
if type(i)~="table"or type(a)~="string"then
return l,n,t,r
end
if a==METHOD_ADD then
l,n,t,r=diff_add_data(i)elseif a==METHOD_DELETE then
l,n,t,r=diff_del_data(i)elseif a==METHOD_MODIFY then
l,n,t,r=diff_modify_data(i)else
return e.E_INVFMT,nil,nil,false
end
return l,n,t,r
end
function diff_add_data(d)local n,l,r,_=e.E_INVFMT,{},{},false
local n,n,n,n
local o,a
for n,t in pairs(d)do
if"string"~=type(n)or"table"~=type(t)then
return e.E_INVFMT,nil,nil,false
end
l[n]={}r[n]={}for t,i in pairs(t)do
if"string"~=type(t)or"table"~=type(i)then
return e.E_INVFMT,nil,nil,false
end
o,a=get_name_data(n,t)if e.E_NONE==o then
l[n][t]=a
r[n][t]={}for e,l in pairs(i)do
if a[e]~=l then
r[n][t][e]=l
_=true
end
end
else
l[n][t]={}r[n][t]=i
_=true
end
end
end
return e.E_NONE,l,d,true
end
function diff_del_data(n)return e.E_NONE,{},n,true
end
function diff_modify_data(n)local t,l,r,i=e.E_INVFMT,{},{},false
local t,t,t,t
local d,o
for n,t in pairs(n)do
if"string"~=type(n)or"table"~=type(t)then
return e.E_INVFMT,nil,nil,false
end
l[n]={}r[n]={}for t,a in pairs(t)do
if"string"~=type(t)or"table"~=type(a)then
return e.E_INVFMT,nil,nil,false
end
d,o=get_name_data(n,t)if e.E_NONE==d then
l[n][t]=o
r[n][t]={}for l,e in pairs(a)do
if o[l]~=e then
r[n][t][l]=e
i=true
end
end
else
l[n][t]={}r[n][t]=a
i=true
end
end
end
return e.E_NONE,l,r,i
end
function do_callback(f,_,d,l,c)local n=require("luci.dispatcher")l=l or{}local a=e.E_NONE
local r={}local n=n.context.datacbs or{}function call(o,t,a,i,d,c,_,f)local l=nil
local n=n[a]or{}local n=n[i]or{}local n=n[t]if not n then
return e.E_NONE
end
local r=e.E_NONE
for n,t in pairs(n)do
local n=require(t.module)local n=n[t.func]assert(n~=nil,'Cannot resolve function "'..t.func..'". Is it misspelled or local?')assert(type(n)=="function",'The symbol "'..t.func..'" does not refer to a function but data '..'of type "'..type(n)..'".')r,l=n(o,a,i,d,c,_,f)if r~=e.E_NONE then
return r
end
end
return r,l
end
local n,n=nil
for n,t in pairs(d)do
local i,i=nil
r[n]=r[n]or{}for t,d in pairs(t)do
local o=nil
local _=_[n][t]local i={}if l[n]and l[n][t]then
i=l[n][t]end
a,o=call(c,f,n,t,_,d,i,r)if a~=e.E_NONE then
return a
end
r[n][t]=o or{wait_time=2}end
end
return a,r
end
function do_chkcb(t,r,n,e)return do_callback("chkfunc",t,r,n,e)end
function do_srvcb(e,t,n,r)return do_callback("srvfunc",e,t,n,r)end
function filter_args(l,o,n)n=n or{}if type(l)~="table"then
return e.E_NONE
end
local function _(n,t,a,r,l)local t=n..FILTER_UCI_SEC_SEP..t
local n=e.E_NONE
if uci_secname_filters[t]then
n=filter(uci_secname_filters[t],a,r,l)if n~=e.E_NONE then
return n
end
end
return n
end
local r=e.E_NONE
local t,i,a
for t,l in pairs(l)do
for l,d in pairs(l)do
i=o[t][l]a=n[t]and n[t][l]or nil
r=_(t,l,d,i,a)if e.E_NONE~=r then
return r
end
end
end
return r
end
function filter(n,r,l,t)t=t or{}for a,_ in pairs(r)do
local n=n[a]if n==nil then
l[a]=nil
end
if n and n[filter_key.validator]then
local a=n[filter_key.validator]local o=n[filter_key.args]or{}local a,i=d.split_module_func(a)local n=nil
if a~=nil then
n=require(a)end
local n=n and i and n[i]or nil
local n=n and n(_,r,l,t,unpack(o))n=type(n)=="number"and n or type(n)=="boolean"and n and e.E_NONE or e.E_INVFMT
if n~=e.E_NONE then
return n
end
end
end
return e.E_NONE
end
