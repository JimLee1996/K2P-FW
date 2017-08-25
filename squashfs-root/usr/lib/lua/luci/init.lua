local i=require
if not _G.bit then
_G.bit=i"bit"end
module"luci"local i=i"luci.version"__version__=i.luciversion or"trunk"__appname__=i.luciname or"LuCI"