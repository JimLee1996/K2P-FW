local o=require"luci.util"local s=require"table"local f=require"string"local r=require"coroutine"local n=assert
local u=tonumber
local i=tostring
local d=error
local l=type
local p=pairs
local e=ipairs
local h=next
local t=pcall
local a=getmetatable
module"luci.json"function decode(r,n,...)local e=ActiveDecoder(function()return nil end,...)e.chunk=r
e.func=n
local n,e=t(e.get,e)return n and e or nil
end
function encode(n,...)local e={}local t=Encoder(n,1,...):source()local n,r
repeat
n,r=t()e[#e+1]=n
until not n
return not r and s.concat(e)or nil
end
function null()return null
end
Encoder=o.class()function Encoder.__init__(e,n,r,t)e.data=n
e.buffersize=r or 512
e.buffer=""e.fastescape=t
a(e).__call=Encoder.source
end
function Encoder.source(e)local n=r.create(e.dispatch)return function()local n,e=r.resume(n,e,e.data,true)if n then
return e
else
return nil,e
end
end
end
function Encoder.dispatch(e,n,t)local c=e.parsers[l(n)]c(e,n)if t then
if#e.buffer>0 then
r.yield(e.buffer)end
r.yield()end
end
function Encoder.put(e,t)if e.buffersize<2 then
r.yield(t)else
if#e.buffer+#t>e.buffersize then
local n=0
local c=e.buffersize-#e.buffer
r.yield(e.buffer..t:sub(n+1,c))n=c
while#t-n>e.buffersize do
c=n+e.buffersize
r.yield(t:sub(n+1,c))n=c
end
e.buffer=t:sub(n+1)else
e.buffer=e.buffer..t
end
end
end
function Encoder.parse_nil(e)e:put("null")end
function Encoder.parse_bool(n,e)n:put(e and"true"or"false")end
function Encoder.parse_number(e,n)e:put(i(n))end
function Encoder.parse_string(e,n)if e.fastescape then
e:put('"'..n:gsub('\\','\\\\'):gsub('"','\\"')..'"')else
e:put('"'..n:gsub('[%c\\"]',function(e)return'\\u00%02x'%e:byte()end)..'"')end
end
function Encoder.parse_iter(e,n)if n==null then
return e:put("null")end
if l(n)=="table"and(#n==0 and h(n))then
e:put("{")local r=true
for t,n in p(n)do
r=r or e:put(",")r=r and false
e:parse_string(i(t))e:put(":")e:dispatch(n)end
e:put("}")else
e:put("[")local r=true
if l(n)=="table"then
for t=1,#n do
r=r or e:put(",")r=r and nil
e:dispatch(n[t])end
else
for n in n do
r=r or e:put(",")r=r and nil
e:dispatch(n)end
end
e:put("]")end
end
Encoder.parsers={['nil']=Encoder.parse_nil,['table']=Encoder.parse_iter,['number']=Encoder.parse_number,['string']=Encoder.parse_string,['boolean']=Encoder.parse_bool,['function']=Encoder.parse_iter}Decoder=o.class()function Decoder.__init__(e,n)e.cnull=n
a(e).__call=Decoder.sink
end
function Decoder.sink(e)local n=r.create(e.dispatch)return function(...)return r.resume(n,e,...)end
end
function Decoder.get(e)return e.data
end
function Decoder.dispatch(r,e,o,u)local a,l
local c=false
while e do
while e and#e<1 do
e=r:fetch()end
n(not u or e,"Unexpected EOS")if not e then break end
local t=e:sub(1,1)local t=r.parsers[t]or(t:match("%s")and r.parse_space)or(t:match("[0-9-]")and r.parse_number)or d("Unexpected char '%s'"%t)e,a=t(r,e)if t~=r.parse_space then
n(not c,"Scope violation: Too many objects")l=a
c=true
if u then
return e,l
end
end
end
n(not o,o)n(c,"Unexpected EOS")r.data=l
end
function Decoder.fetch(e)local t,r,e=r.yield()n(r or not e,e)return r
end
function Decoder.fetch_atleast(t,e,r)while#e<r do
local r=t:fetch()n(r,"Unexpected EOS")e=e..r
end
return e
end
function Decoder.fetch_until(c,e,t)local r=e:find(t)while not r do
local c=c:fetch()n(c,"Unexpected EOS")e=e..c
r=e:find(t)end
return e,r
end
function Decoder.parse_space(r,e)local n=e:find("[^%s]")while not n do
e=r:fetch()if not e then
return nil
end
n=e:find("[^%s]")end
return e:sub(n)end
function Decoder.parse_literal(c,r,e,t)r=c:fetch_atleast(r,#e)n(r:sub(1,#e)==e,"Invalid character sequence")return r:sub(#e+1),t
end
function Decoder.parse_null(e,n)return e:parse_literal(n,"null",{})end
function Decoder.parse_true(e,n)return e:parse_literal(n,"true",true)end
function Decoder.parse_false(e,n)return e:parse_literal(n,"false",false)end
function Decoder.parse_number(e,r)local r,t=e:fetch_until(r,"[^0-9eE.+-]")local e=u(r:sub(1,t-1))n(e,"Invalid number specification")return r:sub(t),e
end
function Decoder.parse_string(c,e)local r=""local l=nil
n(e:sub(1,1)=='"','Expected "')e=e:sub(2)while true do
local t=e:find('[\\"]')if t then
r=r..e:sub(1,t-1)local n=e:sub(t,t)if n=='"'then
e=e:sub(t+1)break
elseif n=="\\"then
e,l=c:parse_escape(e:sub(t))r=r..l
end
else
r=r..e
e=c:fetch()n(e,"Unexpected EOS while parsing a string")end
end
if c["func"]then
r=c["func"](r)end
return e,r
end
function Decoder.parse_escape(t,e)local r=""e=t:fetch_atleast(e:sub(2),1)local r=e:sub(1,1)e=e:sub(2)if r=='"'then
return e,'"'elseif r=="\\"then
return e,"\\"elseif r=="u"then
e=t:fetch_atleast(e,4)local r,t=e:sub(1,2),e:sub(3,4)r,t=u(r,16),u(t,16)n(r and t,"Invalid Unicode character")return e:sub(5),r==0 and f.char(t)or""elseif r=="/"then
return e,"/"elseif r=="b"then
return e,"\b"elseif r=="f"then
return e,"\f"elseif r=="n"then
return e,"\n"elseif r=="r"then
return e,"\r"elseif r=="t"then
return e,"\t"else
d("Unexpected escaping sequence '\\%s'"%r)end
end
function Decoder.parse_array(l,e)e=e:sub(2)local t={}local c=1
local r,e=l:parse_delimiter(e,"%]")if e then
return r,t
end
repeat
r,e=l:dispatch(r,nil,true)s.insert(t,c,e)c=c+1
r,e=l:parse_delimiter(r,",%]")n(e,"Delimiter expected")until e=="]"return r,t
end
function Decoder.parse_object(t,e)e=e:sub(2)local c={}local l
local e,r=t:parse_delimiter(e,"}")if r then
return e,c
end
repeat
e=t:parse_space(e)n(e,"Unexpected EOS")e,l=t:parse_string(e)e,r=t:parse_delimiter(e,":")n(r,"Separator expected")e,r=t:dispatch(e,nil,true)c[l]=r
e,r=t:parse_delimiter(e,",}")n(r,"Delimiter expected")until r=="}"return e,c
end
function Decoder.parse_delimiter(t,e,c)while true do
e=t:fetch_atleast(e,1)local r=e:sub(1,1)if r:match("%s")then
e=t:parse_space(e)n(e,"Unexpected EOS")elseif r:match("[%s]"%c)then
return e:sub(2),r
else
return e,nil
end
end
end
Decoder.parsers={['"']=Decoder.parse_string,['t']=Decoder.parse_true,['f']=Decoder.parse_false,['n']=Decoder.parse_null,['[']=Decoder.parse_array,['{']=Decoder.parse_object}ActiveDecoder=o.class(Decoder)function ActiveDecoder.__init__(e,r,n)Decoder.__init__(e,n)e.source=r
e.chunk=nil
a(e).__call=e.get
end
function ActiveDecoder.get(e)local n,t,r
if not e.chunk then
n,t=e.source()else
n=e.chunk
end
e.chunk,r=e:dispatch(n,t,true)return r
end
function ActiveDecoder.fetch(e)local r,e=e.source()n(r or not e,e)return r
end
