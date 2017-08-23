module("luci.controller.admin.device_mng",package.seeall)function index()entry({"pc","deviceManage.htm"},template("pc/deviceManage")).leaf=true
entry({"h5","deviceManage.htm"},template("h5/deviceManage")).leaf=true
entry({"h5","editClient.htm"},template("h5/editClient")).leaf=true
register_keyword_data("device_manage","client_list","get_client_list")end
function get_client_list()local e,t
local i=require("luci.adapter.device_mng")e,t=i.client_list()return e,t
end
