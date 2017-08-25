local e=require("luci.phicomm.error")module("luci.controller.admin.system_status",package.seeall)function index()entry({"pc","routerInfo.htm"},template("pc/routerInfo")).leaf=true
end
