module("luci.cbi",package.seeall)require("luci.template")local l=require("luci.util")require("luci.http")local r=require("nixio.fs")local u=require("luci.model.uci")local d=require("luci.cbi.datatypes")local n=l.class
local a=l.instanceof
FORM_NODATA=0
FORM_PROCEED=0
FORM_VALID=1
FORM_DONE=1
FORM_INVALID=-1
FORM_CHANGED=2
FORM_SKIP=4
AUTO=true
CREATE_PREFIX="cbi.cts."REMOVE_PREFIX="cbi.rts."RESORT_PREFIX="cbi.sts."FEXIST_PREFIX="cbi.cbe."function load(n,...)local o=require"nixio.fs"local i=require"luci.i18n"require("luci.config")require("luci.util")local s="/lib/uci/upload/"local r=luci.util.libpath().."/model/cbi/"local e,t
if o.access(r..n..".lua")then
e,t=loadfile(r..n..".lua")elseif o.access(n)then
e,t=loadfile(n)else
e,t=nil,"Model '"..n.."' not found!"end
assert(e,t)local n={translate=i.translate,translatef=i.translatef,arg={...}}setfenv(e,setmetatable(n,{__index=function(n,e)return rawget(n,e)or _M[e]or _G[e]end}))local r={e()}local o={}local n=false
for t,e in ipairs(r)do
if not a(e,Node)then
error("CBI map returns no valid map object!")return nil
else
e:prepare()if e.upload_fields then
n=true
for n,e in ipairs(e.upload_fields)do
o[e.config..'.'..(e.section.sectiontype or'1')..'.'..e.option]=true
end
end
end
end
if n then
local u=luci.model.uci.cursor()local c=luci.http.context.request.message.params
local e,t
luci.http.setfilehandler(function(n,d,l)if not n then return end
if n.name and not t then
local a,i,r=n.name:gmatch("cbid%.([^%.]+)%.([^%.]+)%.([^%.]+)")()if a and i and r then
local i=u:get(a,i)or i
if o[a.."."..i.."."..r]then
local a=s..n.name
e=io.open(a,"w")if e then
t=n.name
c[t]=a
end
end
end
end
if n.name==t and e then
e:write(d)end
if l and e then
e:close()e=nil
t=nil
end
end)end
return r
end
local i={}function compile_datatype(r)local e
local o=0
local n=false
local a=0
local e={}for t=1,#r+1 do
local i=r:byte(t)or 44
if n then
n=false
elseif i==92 then
n=true
elseif i==40 or i==44 then
if a<=0 then
if o<t then
local n=r:sub(o,t-1):gsub("\\(.)","%1"):gsub("^%s+",""):gsub("%s+$","")if#n>0 and tonumber(n)then
e[#e+1]=tonumber(n)elseif n:match("^'.*'$")or n:match('^".*"$')then
e[#e+1]=n:gsub("[\"'](.*)[\"']","%1")elseif type(d[n])=="function"then
e[#e+1]=d[n]e[#e+1]={}else
error("Datatype error, bad token %q"%n)end
end
o=t+1
end
a=a+(i==40 and 1 or 0)elseif i==41 then
a=a-1
if a<=0 then
if type(e[#e-1])~="function"then
error("Datatype error, argument list follows non-function")end
e[#e]=compile_datatype(r:sub(o,t-1))o=t+1
end
end
end
return e
end
function verify_datatype(e,t)if e and#e>0 then
if not i[e]then
local n=compile_datatype(e)if n and type(n[1])=="function"then
i[e]=n
else
error("Datatype error, not a function expression")end
end
if i[e]then
return i[e][1](t,unpack(i[e][2]))end
end
return true
end
Node=n()function Node.__init__(e,t,n)e.children={}e.title=t or""e.description=n or""e.template="cbi/node"end
function Node._run_hook(e,n)if type(e[n])=="function"then
return e[n](e)end
end
function Node._run_hooks(e,...)local n
local t=false
for a,n in ipairs(arg)do
if type(e[n])=="function"then
e[n](e)t=true
end
end
return t
end
function Node.prepare(e,...)for n,e in ipairs(e.children)do
e:prepare(...)end
end
function Node.append(n,e)table.insert(n.children,e)end
function Node.parse(e,...)for n,e in ipairs(e.children)do
e:parse(...)end
end
function Node.render(n,e)e=e or{}e.self=n
luci.template.render(n.template,e)end
function Node.render_children(e,...)local n,n
for t,n in ipairs(e.children)do
n.last_child=(t==#e.children)n:render(...)end
end
Template=n(Node)function Template.__init__(e,n)Node.__init__(e)e.template=n
end
function Template.render(e)luci.template.render(e.template,{self=e})end
function Template.parse(e,n)e.readinput=(n~=false)return Map.formvalue(e,"cbi.submit")and FORM_DONE or FORM_NODATA
end
Map=n(Node)function Map.__init__(e,n,...)Node.__init__(e,...)e.config=n
e.parsechain={e.config}e.template="cbi/map"e.apply_on_parse=nil
e.readinput=true
e.proceed=false
e.flow={}e.uci=u.cursor()e.save=true
e.changed=false
if not e.uci:load(e.config)then
error("Unable to read UCI data: "..e.config)end
end
function Map.formvalue(e,n)return e.readinput and luci.http.formvalue(n)end
function Map.formvaluetable(e,n)return e.readinput and luci.http.formvaluetable(n)or{}end
function Map.get_scheme(e,n,t)if not t then
return e.scheme and e.scheme.sections[n]else
return e.scheme and e.scheme.variables[n]and e.scheme.variables[n][t]end
end
function Map.submitstate(e)return e:formvalue("cbi.submit")end
function Map.chain(n,e)table.insert(n.parsechain,e)end
function Map.state_handler(n,e)return e
end
function Map.parse(e,n,...)e.readinput=(n~=false)e:_run_hooks("on_parse")if e:formvalue("cbi.skip")then
e.state=FORM_SKIP
return e:state_handler(e.state)end
Node.parse(e,...)if e.save then
e:_run_hooks("on_save","on_before_save")for t,n in ipairs(e.parsechain)do
e.uci:save(n)end
e:_run_hooks("on_after_save")if e:submitstate()and((not e.proceed and e.flow.autoapply)or luci.http.formvalue("cbi.apply"))then
e:_run_hooks("on_before_commit")for t,n in ipairs(e.parsechain)do
e.uci:commit(n)e.uci:load(n)end
e:_run_hooks("on_commit","on_after_commit","on_before_apply")if e.apply_on_parse then
e.uci:apply(e.parsechain)e:_run_hooks("on_apply","on_after_apply")else
e.apply_needed=true
end
Node.parse(e,true)end
for t,n in ipairs(e.parsechain)do
e.uci:unload(n)end
if type(e.commit_handler)=="function"then
e:commit_handler(e:submitstate())end
end
if e:submitstate()then
if not e.save then
e.state=FORM_INVALID
elseif e.proceed then
e.state=FORM_PROCEED
else
e.state=e.changed and FORM_CHANGED or FORM_VALID
end
else
e.state=FORM_NODATA
end
return e:state_handler(e.state)end
function Map.render(e,...)e:_run_hooks("on_init")Node.render(e,...)end
function Map.section(n,e,...)if a(e,AbstractSection)then
local e=e(n,...)n:append(e)return e
else
error("class must be a descendent of AbstractSection")end
end
function Map.add(e,n)return e.uci:add(e.config,n)end
function Map.set(e,t,a,n)if type(n)~="table"or#n>0 then
if a then
return e.uci:set(e.config,t,a,n)else
return e.uci:set(e.config,t,n)end
else
return Map.del(e,t,a)end
end
function Map.del(e,n,t)if t then
return e.uci:delete(e.config,n,t)else
return e.uci:delete(e.config,n)end
end
function Map.get(e,n,t)if not n then
return e.uci:get_all(e.config)elseif t then
return e.uci:get(e.config,n,t)else
return e.uci:get_all(e.config,n)end
end
Compound=n(Node)function Compound.__init__(e,...)Node.__init__(e)e.template="cbi/compound"e.children={...}end
function Compound.populate_delegator(n,e)for t,n in ipairs(n.children)do
n.delegator=e
end
end
function Compound.parse(t,...)local n,e=0
for a,t in ipairs(t.children)do
n=t:parse(...)e=(not e or n<e)and n or e
end
return e
end
Delegator=n(Node)function Delegator.__init__(e,...)Node.__init__(e,...)e.nodes={}e.defaultpath={}e.pageaction=false
e.readinput=true
e.allow_reset=false
e.allow_cancel=false
e.allow_back=false
e.allow_finish=false
e.template="cbi/delegator"end
function Delegator.set(n,e,t)assert(not n.nodes[e],"Duplicate entry")n.nodes[e]=t
end
function Delegator.add(e,t,n)n=e:set(t,n)e.defaultpath[#e.defaultpath+1]=t
end
function Delegator.insert_after(e,t,a)local n=#e.chain+1
for e,t in ipairs(e.chain)do
if t==a then
n=e+1
break
end
end
table.insert(e.chain,n,t)end
function Delegator.set_route(t,...)local e,n,i=0,t.chain,{...}for a=1,#n do
if n[a]==t.current then
e=a
break
end
end
for t=1,#i do
e=e+1
n[e]=i[t]end
for e=e+1,#n do
n[e]=nil
end
end
function Delegator.get(e,n)local e=e.nodes[n]if type(e)=="string"then
e=load(e,n)end
if type(e)=="table"and getmetatable(e)==nil then
e=Compound(unpack(e))end
return e
end
function Delegator.parse(e,...)if e.allow_cancel and Map.formvalue(e,"cbi.cancel")then
if e:_run_hooks("on_cancel")then
return FORM_DONE
end
end
if not Map.formvalue(e,"cbi.delg.current")then
e:_run_hooks("on_init")end
local t
e.chain=e.chain or e:get_chain()e.current=e.current or e:get_active()e.active=e.active or e:get(e.current)assert(e.active,"Invalid state")local n=FORM_DONE
if type(e.active)~="function"then
e.active:populate_delegator(e)n=e.active:parse()else
e:active()end
if n>FORM_PROCEED then
if Map.formvalue(e,"cbi.delg.back")then
t=e:get_prev(e.current)else
t=e:get_next(e.current)end
elseif n<FORM_PROCEED then
return n
end
if not Map.formvalue(e,"cbi.submit")then
return FORM_NODATA
elseif n>FORM_PROCEED
and(not t or not e:get(t))then
return e:_run_hook("on_done")or FORM_DONE
else
e.current=t or e.current
e.active=e:get(e.current)if type(e.active)~="function"then
e.active:populate_delegator(e)local n=e.active:parse(false)if n==FORM_SKIP then
return e:parse(...)else
return FORM_PROCEED
end
else
return e:parse(...)end
end
end
function Delegator.get_next(e,t)for n,a in ipairs(e.chain)do
if a==t then
return e.chain[n+1]end
end
end
function Delegator.get_prev(e,a)for t,n in ipairs(e.chain)do
if n==a then
return e.chain[t-1]end
end
end
function Delegator.get_chain(e)local e=Map.formvalue(e,"cbi.delg.path")or e.defaultpath
return type(e)=="table"and e or{e}end
function Delegator.get_active(e)return Map.formvalue(e,"cbi.delg.current")or e.chain[1]end
Page=n(Node)Page.__init__=Node.__init__
Page.parse=function()end
SimpleForm=n(Node)function SimpleForm.__init__(e,i,a,t,n)Node.__init__(e,a,t)e.config=i
e.data=n or{}e.template="cbi/simpleform"e.dorender=true
e.pageaction=false
e.readinput=true
end
SimpleForm.formvalue=Map.formvalue
SimpleForm.formvaluetable=Map.formvaluetable
function SimpleForm.parse(e,n,...)e.readinput=(n~=false)if e:formvalue("cbi.skip")then
return FORM_SKIP
end
if e:formvalue("cbi.cancel")and e:_run_hooks("on_cancel")then
return FORM_DONE
end
if e:submitstate()then
Node.parse(e,1,...)end
local n=true
for t,e in ipairs(e.children)do
for t,e in ipairs(e.children)do
n=n
and(not e.tag_missing or not e.tag_missing[1])and(not e.tag_invalid or not e.tag_invalid[1])and(not e.error)end
end
local n=not e:submitstate()and FORM_NODATA
or n and FORM_VALID
or FORM_INVALID
e.dorender=not e.handle
if e.handle then
local t,a=e:handle(n,e.data)e.dorender=e.dorender or(t~=false)n=a or n
end
return n
end
function SimpleForm.render(e,...)if e.dorender then
Node.render(e,...)end
end
function SimpleForm.submitstate(e)return e:formvalue("cbi.submit")end
function SimpleForm.section(e,n,...)if a(n,AbstractSection)then
local n=n(e,...)e:append(n)return n
else
error("class must be a descendent of AbstractSection")end
end
function SimpleForm.field(n,t,...)local e
for t,n in ipairs(n.children)do
if a(n,SimpleSection)then
e=n
break
end
end
if not e then
e=n:section(SimpleSection)end
if a(t,AbstractValue)then
local n=t(n,e,...)n.track_missing=true
e:append(n)return n
else
error("class must be a descendent of AbstractValue")end
end
function SimpleForm.set(t,a,e,n)t.data[e]=n
end
function SimpleForm.del(n,t,e)n.data[e]=nil
end
function SimpleForm.get(e,t,n)return e.data[n]end
function SimpleForm.get_scheme()return nil
end
Form=n(SimpleForm)function Form.__init__(e,...)SimpleForm.__init__(e,...)e.embedded=true
end
AbstractSection=n(Node)function AbstractSection.__init__(e,n,t,...)Node.__init__(e,...)e.sectiontype=t
e.map=n
e.config=n.config
e.optionals={}e.defaults={}e.fields={}e.tag_error={}e.tag_invalid={}e.tag_deperror={}e.changed=false
e.optional=true
e.addremove=false
e.dynamic=false
end
function AbstractSection.tab(e,n,a,t)e.tabs=e.tabs or{}e.tab_names=e.tab_names or{}e.tab_names[#e.tab_names+1]=n
e.tabs[n]={title=a,description=t,childs={}}end
function AbstractSection.has_tabs(e)return(e.tabs~=nil)and(next(e.tabs)~=nil)end
function AbstractSection.option(e,t,i,...)if a(t,AbstractValue)then
local n=t(e.map,e,i,...)e:append(n)e.fields[i]=n
return n
elseif t==true then
error("No valid class was given and autodetection failed.")else
error("class must be a descendant of AbstractValue")end
end
function AbstractSection.taboption(e,n,...)assert(n and e.tabs and e.tabs[n],"Cannot assign option to not existing tab %q"%tostring(n))local n=e.tabs[n].childs
local e=AbstractSection.option(e,...)if e then n[#n+1]=e end
return e
end
function AbstractSection.render_tab(n,e,...)assert(e and n.tabs and n.tabs[e],"Cannot render not existing tab %q"%tostring(e))local t,t
for a,t in ipairs(n.tabs[e].childs)do
t.last_child=(a==#n.tabs[e].childs)t:render(...)end
end
function AbstractSection.parse_optionals(e,t)if not e.optional then
return
end
e.optionals[t]={}local n=e.map:formvalue("cbi.opt."..e.config.."."..t)for i,a in ipairs(e.children)do
if a.optional and not a:cfgvalue(t)and not e:has_tabs()then
if n==a.option then
n=nil
e.map.proceed=true
else
table.insert(e.optionals[t],a)end
end
end
if n and#n>0 and e.dynamic then
e:add_dynamic(n)end
end
function AbstractSection.add_dynamic(t,e,n)local e=t:option(Value,e,e)e.optional=n
end
function AbstractSection.parse_dynamic(e,n)if not e.dynamic then
return
end
local t=luci.util.clone(e:cfgvalue(n))local n=e.map:formvaluetable("cbid."..e.config.."."..n)for e,n in pairs(n)do
t[e]=n
end
for n,t in pairs(t)do
local t=true
for a,e in ipairs(e.children)do
if e.option==n then
t=false
end
end
if t and n:sub(1,1)~="."then
e.map.proceed=true
e:add_dynamic(n,true)end
end
end
function AbstractSection.cfgvalue(e,n)return e.map:get(n)end
function AbstractSection.push_events(e)e.map.changed=true
end
function AbstractSection.remove(e,n)e.map.proceed=true
return e.map:del(n)end
function AbstractSection.create(e,n)local t
if n then
t=n:match("^[%w_]+$")and e.map:set(n,nil,e.sectiontype)else
n=e.map:add(e.sectiontype)t=n
end
if t then
for a,t in pairs(e.children)do
if t.default then
e.map:set(n,t.option,t.default)end
end
for a,t in pairs(e.defaults)do
e.map:set(n,a,t)end
end
e.map.proceed=true
return t
end
SimpleSection=n(AbstractSection)function SimpleSection.__init__(e,n,...)AbstractSection.__init__(e,n,nil,...)e.template="cbi/nullsection"end
Table=n(AbstractSection)function Table.__init__(n,e,a,...)local e={}local t=n
e.config="table"n.data=a or{}e.formvalue=Map.formvalue
e.formvaluetable=Map.formvaluetable
e.readinput=true
function e.get(a,e,n)return t.data[e]and t.data[e][n]end
function e.submitstate(e)return Map.formvalue(e,"cbi.submit")end
function e.del(...)return true
end
function e.get_scheme()return nil
end
AbstractSection.__init__(n,e,"table",...)n.template="cbi/tblsection"n.rowcolors=true
n.anonymous=true
end
function Table.parse(e,n)e.map.readinput=(n~=false)for t,n in ipairs(e:cfgsections())do
if e.map:submitstate()then
Node.parse(e,n)end
end
end
function Table.cfgsections(n)local e={}for n,t in luci.util.kspairs(n.data)do
table.insert(e,n)end
return e
end
function Table.update(n,e)n.data=e
end
NamedSection=n(AbstractSection)function NamedSection.__init__(e,a,n,t,...)AbstractSection.__init__(e,a,t,...)e.addremove=false
e.template="cbi/nsection"e.section=n
end
function NamedSection.parse(e,n)local n=e.section
local t=e:cfgvalue(n)if e.addremove then
local a=e.config.."."..n
if t then
if e.map:formvalue("cbi.rns."..a)and e:remove(n)then
e:push_events()return
end
else
if e.map:formvalue("cbi.cns."..a)then
e:create(n)return
end
end
end
if t then
AbstractSection.parse_dynamic(e,n)if e.map:submitstate()then
Node.parse(e,n)end
AbstractSection.parse_optionals(e,n)if e.changed then
e:push_events()end
end
end
TypedSection=n(AbstractSection)function TypedSection.__init__(e,t,n,...)AbstractSection.__init__(e,t,n,...)e.template="cbi/tsection"e.deps={}e.anonymous=false
end
function TypedSection.cfgsections(e)local n={}e.map.uci:foreach(e.map.config,e.sectiontype,function(t)if e:checkscope(t[".name"])then
table.insert(n,t[".name"])end
end)return n
end
function TypedSection.depends(n,t,e)table.insert(n.deps,{option=t,value=e})end
function TypedSection.parse(e,t)if e.addremove then
local n=REMOVE_PREFIX..e.config
local n=e.map:formvaluetable(n)for n,t in pairs(n)do
if n:sub(-2)==".x"then
n=n:sub(1,#n-2)end
if e:cfgvalue(n)and e:checkscope(n)then
e:remove(n)end
end
end
local n
for a,n in ipairs(e:cfgsections())do
AbstractSection.parse_dynamic(e,n)if e.map:submitstate()then
Node.parse(e,n,t)end
AbstractSection.parse_optionals(e,n)end
if e.addremove then
local t
local n=CREATE_PREFIX..e.config.."."..e.sectiontype
local a,n=next(e.map:formvaluetable(n))if e.anonymous then
if n then
t=e:create(nil,a)end
else
if n then
if e:cfgvalue(n)then
n=nil;end
n=e:checkscope(n)if not n then
e.err_invalid=true
end
if n and#n>0 then
t=e:create(n,a)and n
if not t then
e.invalid_cts=true
end
end
end
end
if t then
AbstractSection.parse_optionals(e,t)end
end
if e.sortable then
local n=RESORT_PREFIX..e.config.."."..e.sectiontype
local t=e.map:formvalue(n)if t and#t>0 then
local n
local n=0
for t in l.imatch(t)do
e.map.uci:reorder(e.config,t,n)n=n+1
end
e.changed=(n>0)end
end
if created or e.changed then
e:push_events()end
end
function TypedSection.checkscope(e,n)if e.filter and not e:filter(n)then
return nil
end
if#e.deps>0 and e:cfgvalue(n)then
local t=false
for i,a in ipairs(e.deps)do
if e:cfgvalue(n)[a.option]==a.value then
t=true
end
end
if not t then
return nil
end
end
return e:validate(n)end
function TypedSection.validate(n,e)return e
end
AbstractValue=n(Node)function AbstractValue.__init__(e,n,a,t,...)Node.__init__(e,...)e.section=a
e.option=t
e.map=n
e.config=n.config
e.tag_invalid={}e.tag_missing={}e.tag_reqerror={}e.tag_error={}e.deps={}e.subdeps={}e.track_missing=false
e.rmempty=true
e.default=nil
e.size=nil
e.optional=false
end
function AbstractValue.prepare(e)e.cast=e.cast or"string"end
function AbstractValue.depends(a,n,t)local e
if type(n)=="string"then
e={}e[n]=t
else
e=n
end
table.insert(a.deps,{deps=e,add=""})end
function AbstractValue.cbid(e,n)return"cbid."..e.map.config.."."..n.."."..e.option
end
function AbstractValue.formcreated(e,n)local n="cbi.opt."..e.config.."."..n
return(e.map:formvalue(n)==e.option)end
function AbstractValue.formvalue(e,n)return e.map:formvalue(e:cbid(n))end
function AbstractValue.additional(n,e)n.optional=e
end
function AbstractValue.mandatory(n,e)n.rmempty=not e
end
function AbstractValue.add_error(e,n,t,a)e.error=e.error or{}e.error[n]=a or t
e.section.error=e.section.error or{}e.section.error[n]=e.section.error[n]or{}table.insert(e.section.error[n],a or t)if t=="invalid"then
e.tag_invalid[n]=true
elseif t=="missing"then
e.tag_missing[n]=true
end
e.tag_error[n]=true
e.map.save=false
end
function AbstractValue.parse(n,t,o)local e=n:formvalue(t)local a=n:cfgvalue(t)if type(e)=="table"and type(a)=="table"then
local n=#e==#a
if n then
for t=1,#e do
if a[t]~=e[t]then
n=false
end
end
end
if n then
e=a
end
end
if e and#e>0 then
local i
e,i=n:validate(e,t)e=n:transform(e)if not e and not o then
n:add_error(t,"invalid",i)end
if e and(n.forcewrite or not(e==a))then
if n:write(t,e)then
n.section.changed=true
end
end
else
if n.rmempty or n.optional then
if n:remove(t)then
n.section.changed=true
end
elseif a~=e and not o then
local a,e=n:validate(nil,t)n:add_error(t,"missing",e)end
end
end
function AbstractValue.render(e,t,n)if not e.optional or e.section:has_tabs()or e:cfgvalue(t)or e:formcreated(t)then
n=n or{}n.section=t
n.cbid=e:cbid(t)Node.render(e,n)end
end
function AbstractValue.cfgvalue(n,t)local e
if n.tag_error[t]then
e=n:formvalue(t)else
e=n.map:get(t,n.option)end
if not e then
return nil
elseif not n.cast or n.cast==type(e)then
return e
elseif n.cast=="string"then
if type(e)=="table"then
return e[1]end
elseif n.cast=="table"then
return{e}end
end
function AbstractValue.validate(n,e)if n.datatype and e then
if type(e)=="table"then
local t
for t,e in ipairs(e)do
if e and#e>0 and not verify_datatype(n.datatype,e)then
return nil
end
end
else
if not verify_datatype(n.datatype,e)then
return nil
end
end
end
return e
end
AbstractValue.transform=AbstractValue.validate
function AbstractValue.write(e,n,t)return e.map:set(n,e.option,t)end
function AbstractValue.remove(e,n)return e.map:del(n,e.option)end
Value=n(AbstractValue)function Value.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/value"e.keylist={}e.vallist={}end
function Value.reset_values(e)e.keylist={}e.vallist={}end
function Value.value(n,t,e)e=e or t
table.insert(n.keylist,tostring(t))table.insert(n.vallist,tostring(e))end
DummyValue=n(AbstractValue)function DummyValue.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/dvalue"e.value=nil
end
function DummyValue.cfgvalue(e,t)local n
if e.value then
if type(e.value)=="function"then
n=e:value(t)else
n=e.value
end
else
n=AbstractValue.cfgvalue(e,t)end
return n
end
function DummyValue.parse(e)end
Flag=n(AbstractValue)function Flag.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/fvalue"e.enabled="1"e.disabled="0"e.default=e.disabled
end
function Flag.parse(e,n)local t=e.map:formvalue(FEXIST_PREFIX..e.config.."."..n.."."..e.option)if t then
local t=e:formvalue(n)and e.enabled or e.disabled
if t~=e.default or(not e.optional and not e.rmempty)then
e:write(n,t)else
e:remove(n)end
else
e:remove(n)end
end
function Flag.cfgvalue(e,n)return AbstractValue.cfgvalue(e,n)or e.default
end
ListValue=n(AbstractValue)function ListValue.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/lvalue"e.keylist={}e.vallist={}e.size=1
e.widget="select"end
function ListValue.reset_values(e)e.keylist={}e.vallist={}end
function ListValue.value(e,n,t,...)if luci.util.contains(e.keylist,n)then
return
end
t=t or n
table.insert(e.keylist,tostring(n))table.insert(e.vallist,tostring(t))for a,t in ipairs({...})do
e.subdeps[#e.subdeps+1]={add="-"..n,deps=t}end
end
function ListValue.validate(n,e)if luci.util.contains(n.keylist,e)then
return e
else
return nil
end
end
MultiValue=n(AbstractValue)function MultiValue.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/mvalue"e.keylist={}e.vallist={}e.widget="checkbox"e.delimiter=" "end
function MultiValue.render(e,...)if e.widget=="select"and not e.size then
e.size=#e.vallist
end
AbstractValue.render(e,...)end
function MultiValue.reset_values(e)e.keylist={}e.vallist={}end
function MultiValue.value(e,t,n)if luci.util.contains(e.keylist,t)then
return
end
n=n or t
table.insert(e.keylist,tostring(t))table.insert(e.vallist,tostring(n))end
function MultiValue.valuelist(n,e)local e=n:cfgvalue(e)if not(type(e)=="string")then
return{}end
return luci.util.split(e,n.delimiter)end
function MultiValue.validate(t,e)e=(type(e)=="table")and e or{e}local n
for a,e in ipairs(e)do
if luci.util.contains(t.keylist,e)then
n=n and(n..t.delimiter..e)or e
end
end
return n
end
StaticList=n(MultiValue)function StaticList.__init__(e,...)MultiValue.__init__(e,...)e.cast="table"e.valuelist=e.cfgvalue
if not e.override_scheme
and e.map:get_scheme(e.section.sectiontype,e.option)then
local n=e.map:get_scheme(e.section.sectiontype,e.option)if e.value and n.values and not e.override_values then
for t,n in pairs(n.values)do
e:value(t,n)end
end
end
end
function StaticList.validate(t,e)e=(type(e)=="table")and e or{e}local n={}for a,e in ipairs(e)do
if luci.util.contains(t.keylist,e)then
table.insert(n,e)end
end
return n
end
DynamicList=n(AbstractValue)function DynamicList.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/dynlist"e.cast="table"e.keylist={}e.vallist={}end
function DynamicList.reset_values(e)e.keylist={}e.vallist={}end
function DynamicList.value(t,n,e)e=e or n
table.insert(t.keylist,tostring(n))table.insert(t.vallist,tostring(e))end
function DynamicList.write(t,a,e)local n={}if type(e)=="table"then
local t
for t,e in ipairs(e)do
if e and#e>0 then
n[#n+1]=e
end
end
else
n={e}end
if t.cast=="string"then
e=table.concat(n," ")else
e=n
end
return AbstractValue.write(t,a,e)end
function DynamicList.cfgvalue(e,n)local e=AbstractValue.cfgvalue(e,n)if type(e)=="string"then
local n
local n={}for t in e:gmatch("%S+")do
if#t>0 then
n[#n+1]=t
end
end
e=n
end
return e
end
function DynamicList.formvalue(n,e)local e=AbstractValue.formvalue(n,e)if type(e)=="string"then
if n.cast=="string"then
local n
local n={}for t in e:gmatch("%S+")do
n[#n+1]=t
end
e=n
else
e={e}end
end
return e
end
TextValue=n(AbstractValue)function TextValue.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/tvalue"end
Button=n(AbstractValue)function Button.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/button"e.inputstyle=nil
e.rmempty=true
end
FileUpload=n(AbstractValue)function FileUpload.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/upload"if not e.map.upload_fields then
e.map.upload_fields={e}else
e.map.upload_fields[#e.map.upload_fields+1]=e
end
end
function FileUpload.formcreated(e,n)return AbstractValue.formcreated(e,n)or
e.map:formvalue("cbi.rlf."..n.."."..e.option)or
e.map:formvalue("cbi.rlf."..n.."."..e.option..".x")end
function FileUpload.cfgvalue(n,e)local e=AbstractValue.cfgvalue(n,e)if e and r.access(e)then
return e
end
return nil
end
function FileUpload.formvalue(e,t)local n=AbstractValue.formvalue(e,t)if n then
if not e.map:formvalue("cbi.rlf."..t.."."..e.option)and
not e.map:formvalue("cbi.rlf."..t.."."..e.option..".x")then
return n
end
r.unlink(n)e.value=nil
end
return nil
end
function FileUpload.remove(n,t)local e=AbstractValue.formvalue(n,t)if e and r.access(e)then r.unlink(e)end
return AbstractValue.remove(n,t)end
FileBrowser=n(AbstractValue)function FileBrowser.__init__(e,...)AbstractValue.__init__(e,...)e.template="cbi/browser"end
