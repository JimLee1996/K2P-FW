module("luci.phicomm.lib.bit",package.seeall)bit={data32={}}for n=1,32 do
bit.data32[n]=2^(32-n)end
function bit:bit_d2b(e)local d={}for n=1,32 do
if e>=self.data32[n]then
d[n]=1
e=e-self.data32[n]else
d[n]=0
end
end
return d
end
function bit:bit_b2d(e)local n=0
for d=1,32 do
if e[d]==1 then
n=n+2^(32-d)end
end
return n
end
function bit:bit_xor(d,n)local e=self:bit_d2b(d)local t=self:bit_d2b(n)local d={}for n=1,32 do
if e[n]==t[n]then
d[n]=0
else
d[n]=1
end
end
return self:bit_b2d(d)end
function bit:bit_and(n,d)local e=self:bit_d2b(n)local t=self:bit_d2b(d)local d={}for n=1,32 do
if e[n]==1 and t[n]==1 then
d[n]=1
else
d[n]=0
end
end
return self:bit_b2d(d)end
function bit:bit_or(d,n)local e=self:bit_d2b(d)local t=self:bit_d2b(n)local d={}for n=1,32 do
if e[n]==1 or t[n]==1 then
d[n]=1
else
d[n]=0
end
end
return self:bit_b2d(d)end
function bit:bit_not(n)local e=self:bit_d2b(n)local d={}for n=1,32 do
if e[n]==1 then
d[n]=0
else
d[n]=1
end
end
return self:bit_b2d(d)end
function bit:bit_rshift(n,d)local n=self:bit_d2b(n)local e=self:bit_d2b(0)if d<=32 and d>=0 then
for d=1,d do
for d=31,1,-1 do
n[d+1]=n[d]end
n[1]=0
end
e=n
end
return self:bit_b2d(e)end
function bit:bit_lshift(n,d)local n=self:bit_d2b(n)local e=self:bit_d2b(0)if d<=32 and d>=0 then
for d=1,d do
for d=1,31 do
n[d]=n[d+1]end
n[32]=0
end
e=n
end
return self:bit_b2d(e)end
function bit:bit_print(d)local n=""for e=1,32 do
n=n..d[e]end
print(n)end