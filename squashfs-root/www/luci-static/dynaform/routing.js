function load(url, id, updateReload){
  var stateHd = {};

  stateHd.enter = function(option){
    var done = option.async();
    var name = this.name;

    loadPage(url + ".htm", id, function(){
      done();

      $('a[data-active]').each(function(){
        if (name.indexOf($(this).attr('data-active')) >= 0){
          $(this).addClass('active');

          var icon = $(this).find("i.icon");
          icon.addClass(icon.attr("data-down"));
        }else{
          $(this).removeClass('active');
          var icon = $(this).find("i.icon");
          icon.removeClass(icon.attr("data-down"));
        }
      });
    });
  };

  if (false !== updateReload){
    stateHd.update = function(option){
      loadPage(url + ".htm", id);
    };
  }

  return stateHd;
}

var stateman = new StateMan();
var h5States = {
  "login": load("login", "Con"),
  "phone": load("menu", "Con", false),
  "phone.netState": load("netState", "Content"),
  "phone.deviceManage": load("deviceManage", "Content"),
  "editClient": load("editClient", "Con"),
  "phone.wifiSet": load("wifiConfig", "Content"),
  "phone.App": load("App", "Content"),
  "networkset": load("networkSet", "Con"),
  "guest": load("guest", "Con"),
  "parentCtrl": load("parentCtrl", "Con"),
  "devList": load("devList", "Con"),
  "parentCtrlRule": load("parentCtrlRule", "Con"),
  "parentCtrlAddRule": load("parentCtrlAddRule", "Con"),
  "diagnose": load("diagnose", "Con"),
  "wisp": load("wisp", "Con"),
  "apList": load("apList", "Con"),
  "setExtend": load("setExtend", "Con"),
  "remoteMng": load("remoteMng", "Con"),
  "screenSet": load("screenSet", "Con"),
  "modifyPwd": load("modifyPwd", "Con"),
  "lanSet": load("lanSet", "Con"),
  //"sysUpgrade": load("sysUpgrade", "Con"),
  "adb":load("adb","Content"),
  "light": load("light", "Con"),
  "timeZone": load("timeZone", "Con")
};

var pcStates = {
  "login": load("login", "Con"),
  "pc": load("menu", "Con", false),
  "pc.netState": load("netState", "Content"),
  "pc.wifiSet": load("wifiConfig", "Content"),
  "pc.App": load("App", "Content"),
  "pc.deviceManage": load("deviceManage", "Content"),
  "pc.networksetApp": load("networkSet", "Content"),
  "pc.guestApp": load("guest", "Content"),
  "pc.parentCtrlApp": load("parentCtrl", "Content"),
  "pc.diagnoseApp": load("diagnose", "Content"),
  "pc.screenSetApp": load("screenSet", "Content"),
  "pc.wispApp": load("wisp", "Content"),
  "pc.setExtendApp": load("setExtend", "Content"),
  "pc.remoteMngApp": load("remoteMng", "Content"),
  "pc.signalSetApp": load("signalSet", "Content"),
  "pc.lanSetApp": load("lanSet", "Content"),
  "pc.sysUpgradeApp": load("sysUpgrade", "Content"),
  "pc.ddnsApp": load("ddns", "Content"),
  "pc.routerInfoApp": load("routerInfo", "Content"),
  "pc.usbStorageApp": load("usbStorage", "Content"),
  "pc.dmzApp": load("dmz", "Content"),
  "pc.backupResetApp": load("backupReset", "Content"),
  "pc.dhcpServerApp": load("dhcp", "Content"),
  "pc.shoppingPriceApp": load("shopPrice", "Content"),
  "pc.autoUpgradeApp": load("sysUpgrade", "Content"),
  "pc.manualUpgradeApp": load("manualUpgrade", "Content"),
  "pc.remotePrinterApp": load("printer", "Content"),
  "pc.safeMngApp": load("safeMng", "Content"),
  "pc.UPnPApp":load("upnp","Content"),
  "pc.portForwadApp": load("portForwad", "Content"),
  "pc.QoSApp":load("qos","Content"),
  "pc.timeZoneApp":load("timeZone","Content"),
  "pc.VPNClientApp":load("vpnClient","Content"),
  "pc.VPNServerApp":load("vpnServer","Content"),
  "pc.wdsApp":load("wds","Content"),
  "pc.setLanApp":load("setLan","Content"),
  "pc.setMainApp":load("setMain","Content"),
  "pc.setSubApp":load("setSub","Content"),
  "pc.lightApp":load("light","Content"),
  "pc.adbApp":load("adb","Content"),
  "pc.adbsetApp":load("adbset","Content"),
  "pc.toolsApp":load("tools","Content"),
  "pc.elinkApp":load("elink","Content"),
  "pc.schemeUpgrade":function(){  // 策略升级
    showLoading(label.versionChecking);
    apiGet({system:{upgrade_info:{action:"upgrade"}}}, function(ret){
      var code = ret[ERR_CODE];
      if (E_NONE == code){
        $.setTimeout(upgradeStatus, 1000);
      }
    });
  }
};

var pcGuideStates = {
	"guide": load("guide", "Con"),
	"setLgPwd": load("setLgPwd", "Con"),
	"guideTimeZone": load("guideTimeZone", "Con"),
	"guideNetworkSet": load("guideNetworkSet", "Con"),
	"guideWifiSet": load("guideWifiSet", "Con"),
	"checkRouterLink": load("checkRouterLink", "Con"),
	"findPppoePwd": load("findPppoePwd", "Con")
};

var h5GuideStates = {
	"guide": load("guide", "Con"),
	"setLgPwd": load("setLgPwd", "Con"),
	"guideTimeZone": load("guideTimeZone", "Con"),
	"userAgreement": load("userAgreement", "Con"),
	"guideNetworkSet": load("guideNetworkSet", "Con"),
	"guideWifiSet": load("guideWifiSet", "Con"),
	"checkRouterLink": load("checkRouterLink", "Con"),
	"findPppoePwd": load("findPppoePwd", "Con")
};

function addState(states, addStates){
	for (var state in addStates){
		states[state] = addStates[state];
	}
}

if (OS.mobile){
  if (1 == ROUTER.guide){
	addState(h5States, h5GuideStates);
  }

  stateman.state(h5States).on("notfound", function(){
    if (1 == ROUTER.guide){
      this.go("guideTimeZone");
    }else{
      this.go("phone.netState");
    }
  });
}else{
  if (1 == ROUTER.guide){
	addState(pcStates, pcGuideStates);
  }

  stateman.state(pcStates).on("notfound", function(){
    if (1 == ROUTER.guide){
      this.go("guideTimeZone");
    }else{
      this.go("pc.netState");
    }
  });
}

var upgradeStatusHd = null;
function upgradeStatus(){
  var para = {
    system:{upgrade_info:{action:"upgrade_status"}}
  };

  apiGet(para, function(ret){
    var info = ret[K_MODULE]["system"]["upgrade_info"];
    var status = info.running_status;
    var code = parseInt(info.status_code, 10);

    if (4 == status){
      if (0 == code){
        clearTimeout(upgradeStatusHd);
        showProgressBar(label.upgrading, label.upgradingTips, ROUTER.time.onlineUpgrade, function(){
          window.location.href = "http://" + ROUTER.domain;
        });

        $.setTimeout(function(){
          // 检测LAN是否可以连接DUT
          lanDetecting(function(){
            window.location.href = "http://" + ROUTER.domain;
          });
        }, ROUTER.time.detectDelay);
      }
    }else if(0 == status){
      clearTimeout(upgradeStatusHd);
      showAlert(label.upgradeFailed);
    }else{
      switch(code){
      case 0:
        showStatus(status);
        upgradeStatusHd = $.setTimeout(upgradeStatus, 1000);
        break;
      default:
        clearTimeout(upgradeStatusHd);
        showAlert(label.upgradeFailed);
        break;
      }
    }
  });
}

function showStatus(status){
  if(1 == status){
    showLoading(label.versionChecking);
  }else if(2 == status){
    showLoading(label.downloadingTip);
  }else if(3 == status){
    showLoading(label.upgradeChecking);
  }
}
