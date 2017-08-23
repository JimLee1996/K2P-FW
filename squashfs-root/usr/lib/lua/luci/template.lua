local l=require"luci.util"local e=require"luci.config"local i=require"luci.template.parser"local o,t,t=tostring,pairs,loadstring
local r,t=setmetatable,loadfile
local a,c,m=getfenv,setfenv,rawget
local t,t,n=assert,type,error
module"luci.template"e.template=e.template or{}viewdir=e.template.viewdir or l.libpath().."/view"context=l.threadlocal()function render(t,e)return Template(t):render(e or a(2))end
Template=l.class()Template.cache=r({},{__mode="v"})function Template.__init__(e,t)e.template=e.cache[t]e.name=t
e.viewns=context.viewns
if not e.template then
local l
local a=viewdir.."/"..t..".htm"e.template,_,l=i.parse(a)if not e.template then
n("Failed to load template '"..t.."'.\n".."Error while parsing template '"..a.."':\n"..(l or"Unknown syntax error"))else
e.cache[t]=e.template
end
end
end
function Template.render(e,t)t=t or a(2)c(e.template,r({},{__index=function(a,l)return m(a,l)or e.viewns[l]or t[l]end}))local l,t=l.copcall(e.template)if not l then
n("Failed to execute template '"..e.name.."'.\n".."A runtime error occured: "..o(t or"(nil)"))end
end
