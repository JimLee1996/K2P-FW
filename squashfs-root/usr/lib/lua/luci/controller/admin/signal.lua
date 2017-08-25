local n=require("luci.phicomm.error")module("luci.controller.admin.signal",package.seeall)function index()entry({"pc","signalSet.htm"},template("pc/signalSet")).leaf=true
register_keyword_data("signal_set","config","get_signal_config")end
function get_signal_config(e)local i={}local e=require"phic"i.power=e.get_wifi_device_config("2.4G","power")and e.get_wifi_device_config("2.4G","power")[1]or"1"return n.E_NONE,i
end