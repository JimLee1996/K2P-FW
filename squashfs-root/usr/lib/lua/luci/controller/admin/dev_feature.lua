local e=require("luci.phicomm.error")module("luci.controller.admin.dev_feature",package.seeall)function index()register_keyword_data("dev_feature","time","get_feature_time")register_keyword_data("dev_feature","app","get_feature_app")register_keyword_data("dev_feature","wifi_2g","get_feature_wifi_2g")register_keyword_data("dev_feature","wifi_5g","get_feature_wifi_5g")end
function get_feature_time()local r=require("luci.model.uci").cursor()local r=r:get_all("dev_feature","time")return e.E_NONE,r
end
function get_feature_app()local r=require("luci.model.uci").cursor()local r=r:get_all("dev_feature","app")return e.E_NONE,r
end
function get_feature_wifi_2g()local r=require("luci.model.uci").cursor()local r=r:get_all("dev_feature","wifi_2g")return e.E_NONE,r
end
function get_feature_wifi_5g()local r=require("luci.model.uci").cursor()local r=r:get_all("dev_feature","wifi_5g")return e.E_NONE,r
end