local r=require("luci.phicomm.error")module("luci.controller.admin.remote_mng",package.seeall)function index()entry({"pc","remoteMng.htm"},template("pc/remoteMng")).leaf=true
entry({"h5","remoteMng.htm"},template("h5/remoteMng")).leaf=true
register_keyword_data("firewall","remote_manager","get_remote_manager_info")end
function get_remote_manager_info()local e=require("luci.model.uci")local e=e.cursor()local e={enable=e:get("remote","remote","remote_enable"),ip=e:get("remote","remote","remote_ip"),port=e:get("remote","remote","remote_port")}return r.E_NONE,e
end
