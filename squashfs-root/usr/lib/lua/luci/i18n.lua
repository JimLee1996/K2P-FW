module("luci.i18n",package.seeall)require("luci.util")local t=require"luci.template.parser"table={}i18ndir=luci.util.libpath().."/i18n/"loaded={}context=luci.util.threadlocal()default="en"function clear()end
function load(t,t,t)end
function loadc(t,t)end
function setlanguage(n)context.lang=n:gsub("_","-")context.parent=(context.lang:match("^([a-z][a-z])_"))if not t.load_catalog(context.lang,i18ndir)then
if context.parent then
t.load_catalog(context.parent,i18ndir)return context.parent
end
end
return context.lang
end
function translate(n)return t.translate(n)or n
end
function translatef(t,...)return tostring(translate(t)):format(...)end
function string(t)return tostring(translate(t))end
function stringf(t,...)return tostring(translate(t)):format(...)end
