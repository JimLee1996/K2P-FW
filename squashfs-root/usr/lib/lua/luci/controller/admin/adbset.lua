local e=require("luci.phicomm.error")
module("luci.controller.admin.adbset",package.seeall)

function index()
entry({"pc","adbset.htm"},template("pc/adbset")).leaf=true
end



