(function(){
  var doc = window.document;

  this.loadExternResource = function(obj)
  {
	var elem, links, scripts, callBack, hasReadyState;
	var head = document.getElementsByTagName("head")[0];
	var ObjOrg = {links:null, scripts:null, callBack:null};

	for(var prop in obj){
	  ObjOrg[prop] = obj[prop];
	}

	links = ObjOrg.links;
	scripts = ObjOrg.scripts;
	callBack = ObjOrg.callBack;

	if(links != undefined){
	  var h = window.screen.height;
	  var w = window.screen.width;
	  var param = "height=" + h + "&width=" + w;

	  for(var i in links){
		var url = links[i].url;
		elem = document.createElement("link");
		elem.rel = "stylesheet";
		elem.href = (url.indexOf("?") >= 0)?(url + "&" + param):(url + "?" + param);
		head.appendChild(elem);
	  }
	}

	if(scripts != undefined){
	  var load, loadHandle, loadCallBack;

	  elem = document.createElement("script");
	  elem.type = "text/javascript";

	  if(callBack != undefined){
		hasReadyState = (elem.readyState != undefined);
		loadCallBack = function(index){
		  scripts[index].loadState = true;

		  for(var j in scripts){
			if(false == scripts[j].loadState){
			  return;
			}
		  }

		  callBack();
		};

		for(var i in scripts){
		  scripts[i].loadState = false;
		}
	  }

	  for(var i in scripts){
		elem = document.createElement("script");
		elem.type = "text/javascript";

			if(callBack != undefined){
			  if(hasReadyState){
				elem.onreadystatechange = (function(index){
				  return function(){
					if(this.readyState == "loaded" || this.readyState == "complete"){
					  this.onreadystatechange = null;
					  loadCallBack(index);
					}
				  };
				})(i);
			  }else{
				elem.onload = (function(index){
				  return function(){
					loadCallBack(index);
				  };
				})(i);
			  }
			}

		elem.src = scripts[i].url;
		head.appendChild(elem);
	  }
	}
  };

  this.OS = {
	windows:		false,
	windowsPhone:	false,
	unixPC:			false,
	iPad:			false,
	iPhone:			false,
	iMacPC:			false,
	iPod:			false,
	android:		false,
	nokia:			false,
	player:			false,
	Android_UC:		false,
	portable:		false,	/* true is handled device; false is large device which is not for handler */
	mobile:			false,

	checkDeviceMode:function (){
	  var pl = navigator.platform;
	  var ua = navigator.userAgent;

	  if (undefined != pl)
	  {
		/* windows or windows phone */
		if (pl.indexOf("Win") >= 0)
		{
		  if (ua.indexOf("Windows Phone") >= 0)
		  {
			this.windowsPhone = true;
			this.windows = true;					
			this.portable = true;
			this.mobile = true;
		  }
		  else
		  {
			this.windows = true;
			this.portable = false;
		  }

		  return;
		}

		/* nokia */
		if (ua.indexOf("NOKIA") >= 0)
		{
		  this.nokia = true;
		  this.portable = true;
		  this.mobile = true;
		  return;
		}

		/* android */
		if (ua.indexOf("Android") >= 0)
		{
		  this.android = true;
		  this.portable = true;
		  this.mobile = true;
		  return;
		}

		/* iPad */
		if (pl.indexOf("iPad") >= 0)
		{
		  this.iPad = true;
		  this.portable = true;
		  this.mobile = false;
		  return;
		}

		/* iPhone */
		if (pl.indexOf("iPhone") >= 0)
		{
		  this.iPhone = true;
		  this.portable = true;
		  this.mobile = true;
		  return;
		}

		/* iPod */
		if (pl.indexOf("iPod") >= 0)
		{
		  this.iPod = true;
		  this.portable = true;
		  this.mobile = true;
		  return;
		}

		/* Wii or PLASTATION which is under version three */
		if ((ua.indexOf("Wii") >= 0) || (ua.indexOf("PLASTATION") >= 0))
		{
		  this.player = true;
		  this.portable = true;
		  this.mobile = true;
		  return;
		}

		/* MacBook of apple */
		if (pl.indexOf("Mac") >= 0)
		{
		  this.iMacPC = true;
		  this.portable = false;
		  this.mobile = false;
		  return;
		}

		/* unix include Linux */
		if ((pl.indexOf("X11") >= 0) || ((pl.indexOf("Linux") >= 0) && (pl.indexOf("arm") < 0)))
		{
		  this.unixPC = true;
		  this.portable = false;
		  this.mobile = false;
		  return;
		}

		return;
	  }
	  else if (ua.indexOf("Android") >= 0)
	  {
		this.android = true;
		this.portable = true;
		this.mobile = true;
		return;
	  }
	  else
	  {
		if (document.body.clientWidth >= 1024 || document.body.clientHeight >= 1024)
		{
		  this.portable = false;
		  this.mobile = false;
		}
		else
		{
		  this.portable = true;
		  this.mobile = true;
		}

		return;
	  }
	}
  };

  OS.checkDeviceMode();

  this.showUpgrade = function(){
	function hideWidget(){
	  $("#xx_widget").hide();
	  $("#xx_cover").hide();
	};

	function initList(id, list, callback){
	  var target = $("#" + id);
	  var ul = $('<ul class="pop-con pop-list"></ul>').insertAfter(target);

	  var len = list.length;
	  for(var i = 0; i < len; i++){
		  $('<li class="item" data-value="' + list[i].value + '">' + list[i].name + '</li>').appendTo(ul);
	  }

	  ul.delegate("li", "click", function(){
		  $(this).parent().hide();
		  callback && callback($(this).attr("data-value"));
	  });

	  target.click(function(e){
		  $(this).next("ul").toggle();
		  e.stopPropagation();
	  });

	  $("body").click(function(e){
		  $(".pop-con").hide();
		  e.stopPropagation();
	  });
	}

	var cover = doc.createElement("div");
	cover.id = "xx_cover";
	doc.body.appendChild(cover);

	var widget = doc.createElement("div");
	var wgtHTML = '<div class="upgrade">'+
			'<div class="upgrade-head">'+
			'<h2 class="title"></h2><img class="logo" src="http://p.to/luci-static/images/phicomm.png?_=20170809165512" alt="PHICOMMM" />'+
			'</div>'+
			'<div class="upgrade-detail">'+
			'<p class="software-info">'+
				'<span class="curent"></span><span id="curent"></span>'+
				'<span class="new"></span><span id="new"></span>'+
				'<span class="release"></span><span id="time"></span>'+
			'</p>'+
			'<h3 class="upgrade-log"></h3>'+
			'<p id="log"></p>'+
			'</div>'+
			'<div class="upgrade-footer">'+
			'<div><span id="upgrade"></span></div>'+
			'<div class="tool-item"><span id="later"></span></div>'+
			'</div>'+
		'</div>';

	widget.id = "xx_widget";
	widget.innerHTML = wgtHTML;
	doc.body.appendChild(widget);

	var toolList = [{name:"1\u5c0f\u65f6\u540e\u63d0\u9192", value:3600},
					{name:"6\u5c0f\u65f6\u540e\u63d0\u9192", value:21600},
					{name:"12\u5c0f\u65f6\u540e\u63d0\u9192", value:43200},
					{name:"24\u5c0f\u65f6\u540e\u63d0\u9192", value:86400},
					{name:"\u4e0d\u518d\u63d0\u9192", value:0}];

	var title = "\u8def\u7531\u5668\u8f6f\u4ef6\u5347\u7ea7\u63d0\u9192"; //路由器软件升级提醒
	var curVer = "\u5f53\u524d\u7248\u672c\uff1a";	// 当前版本
	var newVer = "\u6700\u65b0\u7248\u672c\uff1a";	// 最新版本
	var releaseTime = "\u53d1\u5e03\u65f6\u95f4\uff1a";	// 发布时间
	var log = "\u66f4\u65b0\u5185\u5bb9\uff1a";		// 更新内容:
	var upgrade = "\u7acb\u5373\u5347\u7ea7";	// 立即升级
	var later = "\u7a0d\u540e\u63d0\u9192";	// 稍后提醒
	var failed = "\u8bf7\u6c42\u5931\u8d25";	// 请求失败

	$("h2.title").text(title);
	$("span.curent").text(curVer);
	$("span.new").text(newVer);
	$("span.release").text(releaseTime);
	$("h3.upgrade-log").text(log);

	window["initUpgradeInfo"] = function(ret){
	  console.log(ret);
	  $("#curent").text(ret["fw_version"]).attr("title",ret["fw_version"]);
	  $("#new").text(ret["up_sw_ver"]).attr("title",ret["up_sw_ver"]);
	  $("#time").text(ret["up_pubtime"]).attr("title",ret["up_pubtime"]);
	  $("#log").html(ret["up_desc"]);
	};

	window["upgradeSetHd"] = function(ret){
	  var code = -1;

	  try{
		code = ret["error_code"];
	  }catch(e){}

	  if(0 != code){
		alert(failed);
	  }

	  hideWidget();
	};

	var url = "http://p.to/cgi-bin/scheme_upgrade?type=get&callback=initUpgradeInfo";
	loadExternResource({scripts:[{tag:"script", url:url}]});

	$("#upgrade").text(upgrade).click(function(){
	  window.location.href = "http://p.to/cgi-bin#/pc/schemeUpgrade";
	});

	$("#later").text(later);

	initList("later", toolList, function(val){
	  var url = "http://p.to/cgi-bin/scheme_upgrade?type=set&callback=upgradeSetHd&wait_time=" + val;

	  loadExternResource({scripts:[{tag:"script", url:url}]});
	});
  };

  function loadTheResource(){
	if (!OS.portable){
	  loadExternResource({
		scripts:[{tag:"script", url:"http://p.to/luci-static/lib/jquery.min.js?_=20170809165512"}],
		links:[{tag:"link", url:"http://p.to/luci-static/dynaform/up.css?_=20170809165512"}],
		callBack:function(){
		  showUpgrade();
		}
	  });
	}
  }

  if(doc.readyState === 'complete'){
	loadTheResource();
  }else{
	doc.addEventListener('DOMContentLoaded', function(e){
	  loadTheResource();
	}, false);
  }
})();