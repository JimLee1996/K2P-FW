(function(){
	// 修复有些低版本的浏览器不支持console导致js调用异常
	if (!window.console){
		var names = ["log", "debug", "info", "warn", "error", "assert"];
		window.console = {};
		for (var i = 0; i < names.length; i++){
			window.console[names[i]] = function(){};
		}
	}
})();

function PageFunc()
{
	this.pathStr = "/";
	this.pageStyle = "h5";
	this.htmlPathStr = this.pathStr + this.pageStyle + "/";
	this.loginId = "Login";
	this.coverId = "Cover";
	this.helpIdStr = "helpStr";
	this.LGKEYTIMESTR = "lgKeyTime";

	this.landscapeHdInit = function(){
		var landscapeHd = function(orientation){
			switch(orientation){
			case 90:
			case -90:
				showAlert(label.landscapeTip);
				break;
			default:
				closeAlert();
			}
		};

		(function(){
			if (typeof window.orientation === 'number' && typeof window.onorientationchange === 'object'){
				window.addEventListener('orientationchange', function(){
					landscapeHd(window.orientation);
				}, false);

				landscapeHd(window.orientation);
			}else{
				window.addEventListener('resize',function(){
					if (window.innerWidth > window.innerHeight){
						landscapeHd(90);
					}
				},false);

				if (window.innerWidth > window.innerHeight){
					landscapeHd(90);
				}
			}
		})();
	};
	this.getPageStyle = function(){
		var pageStyle;

		try{
			pageStyle = sessionLS.getItem("pageStyle");
		}catch(e){}

		if (null != pageStyle){
			OS.mobile = ("h5" == pageStyle);
		}

		return OS.mobile;
	};
	this.setPageStyle = function(pageStyle){
		if (false == pageStyle){
			try{
				sessionLS.removeItem("pageStyle");
			}catch(e){}
		}else{
			try{
				sessionLS.setItem("pageStyle", pageStyle);
			}catch(e){}
		}
	};
	this.pageStyleInit = function(style){
		this.pageStyle = style;
		this.htmlPathStr = this.pathStr + this.pageStyle + "/";
	};
	this.$Init = function()
	{
		Load.call(jQuery);
		$.getExplorer();
		$.initUrl();
		$.initSession();
	};
	this.initSwitch = function(switchId, state, callback){
		var thisObj = $("#" + switchId);
		state = state || 0;

		if (1 == state){
			thisObj.attr("data-value", "1").css({textAlign: "right", backgroundColor: "#FE9818"});
			callback && callback(1, true);
		}else{
			thisObj.attr("data-value", "0").css({textAlign: "left", backgroundColor: "#B2B2B2"});
			callback && callback(0, true);
		}

		thisObj.click(function(){
			var val = $(this).attr("data-value");
			if (0 == val){
				$(this).attr("data-value", "1").css({textAlign: "right", backgroundColor: "#FE9818"});
				callback && callback(1, false);
			}else{
				$(this).attr("data-value", "0").css({textAlign: "left", backgroundColor: "#B2B2B2"});
				callback && callback(0, false);
			}
		});
	};
	this.resetSwitch = function(switchId, state){
		var switchObj = $("#" + switchId);
		state = state || 0;

		if (1 == state){
			switchObj.attr("data-value", "1").css({textAlign: "right", backgroundColor: "#FE9818"});
		}else{
			switchObj.attr("data-value", "0").css({textAlign: "left", backgroundColor: "#B2B2B2"});
		}
	};
	this.initRadio = function(id, checkedIdx, callback){
		var checked = "checked";
		var uncheck = "uncheck";
		var radios = $("#" + id + " span.radio");

		var idx = parseInt(checkedIdx, 10);
		var len = radios.length;
		for (var i = 0; i < len; i++){
			if (idx == i){
				$(radios[i]).removeClass(uncheck).addClass(checked).attr("data-idx", i);
			}else{
				$(radios[i]).removeClass(checked).addClass(uncheck).attr("data-idx", i);
			}
		}
		callback && callback(idx);

		radios.click(function(){
			var checked = "checked";
			var uncheck = "uncheck";
			var thisObj = $(this);
			var idx = parseInt(thisObj.attr("data-idx"));

			if (!thisObj.hasClass(checked)){
				thisObj.removeClass(uncheck).addClass(checked);
				thisObj.siblings("span.radio").removeClass(checked).addClass(uncheck);
				callback && callback(idx);
			}
		});
	};
	this.loadPageHandleBg = function(conId)
	{
		$("#" + conId + " input.hover").bind("focus", function(){
			$(".err-note").hide();
			$(this).parent("li.text-con").addClass("text-con-focus");
		}).bind("blur", function(){
			$(this).parent("li.text-con").removeClass("text-con-focus");
		});

		/* 密码显示、隐藏控件，data-value:1->显示，0->隐藏 */
		$("#" + conId + " i.icon-eye").click(function(){
			var val = $(this).attr("data-value");
			if (0 == val){
				$(this).attr("data-value", "1").removeClass("icon_eye_close").addClass("icon_eye_open");
				$(this).prev('input').attr("type", "text");
			}else{
				$(this).attr("data-value", "0").removeClass("icon_eye_open").addClass("icon_eye_close");
				$(this).prev('input').attr("type", "password");
			}
		}).each(function(){
			var val = $(this).attr("data-value") || 0;

			if (1 == val){
				$(this).attr("data-value", "1").removeClass("icon_eye_close").addClass("icon_eye_open");
				$(this).prev('input').attr("type", "text").addClass("text-eye");
			}else{
				$(this).attr("data-value", "0").removeClass("icon_eye_open").addClass("icon_eye_close");
				$(this).prev('input').attr("type", "password").addClass("text-eye");
			}
		});

		var helpInfo = $("div.help");
		if (helpInfo.length > 0){
			$("#HelpIcon").removeClass("disabled");
			id("HelpIcon").onclick = function(){
				var helpDetail = $("div.help ul.help-content").clone();

				$("#Help div.help-info").html(helpDetail);
				$("#Help").addClass("help-show");

				var height = $("#Help").height() + "px";
				$("#Help i.help-back").css("lineHeight", height);
			};
		}else{
			$("#HelpIcon").addClass("disabled");
			id("HelpIcon").onclick = null;
		}

		$("#Help").removeClass("help-show");
	};

	/* load page to the target container */
	this.loadPage = function(url, id, callBack, clearTimer)
	{
		var obj = this;

		/* for the bug of IE6.0 ~ IE8.0 */
		window.setTimeout(function(){
			closeCover();

			$.load(obj.htmlPathStr + url, callBack, id, clearTimer);
		}, 0);
	};

	this.unloadDetail = function(canvasId)
	{
		var detail = id(canvasId);
		if (detail)
		{
			detail.innerHTML = "";
		}
	};

	this.detailShow = function(conId, callBack)
	{
		$("#"+conId).fadeIn(800, callBack);
	};

	this.detailHide = function(conId, canvasId)
	{
		$("#"+conId).fadeOut(800, function(){
			$("#"+conId).css("display", "none");
			window.unloadDetail(canvasId);
		});
	};

	this.selectChange = function(objId, obj)
	{
		id(objId).value = obj.options[obj.selectedIndex].text;
	};

	this.localSgInit = function()
	{
		try
		{
			this.sessionLS.init();
			if (true == isIE && false == isIENormal)
			{
				(function(){
					sessionLS.setExpire(3*1000);
					window.setTimeout(arguments.callee, 1*1000);
				})();
			}
		}catch(ex){}
	};

	this.showUserAgreement = function(){
		loadWidget("userAgreement.htm");
	};

	this.showModifyPwd = function(){
		loadWidget("modifyPwd.htm");
	}

	this.showTimeReboot = function(){
		loadWidget("timeReboot.htm");
	}

	this.loadWidget = function(url, callback){
		var doc = document;

		var cover = doc.createElement("div");
		cover.className = "pop-cover";
		cover.id = "_Cover";
		doc.body.appendChild(cover);

		var pop = doc.createElement("div");
		pop.className = "pop-widget";
		pop.id = "_Widget";
		doc.body.appendChild(pop);

		this.loadPage(url, "_Widget", function(){
			$("#_Cover").fadeIn("fast");
			$("#_Widget").show().find(".close-btn").one("click", function(){
				$("#_Cover").fadeOut("fast", function(){
					$(this).remove();
				});
				$("#_Widget").remove();
			});

			callback && callback();
		}, false);
	};

	this.logout = function()
	{
		apiLogout(function(ret){
			$.setSession("");
			stateman.go("login");
		});
	};

	this.iFrmOnload = function (idStr, callBack)
	{
		var data = {};
		var ifrm = id(idStr);

		try
		{
			var response;
			if (ifrm.contentWindow)
			{
				response = ifrm.contentWindow.document.body ? ifrm.contentWindow.document.body.innerHTML : "";
			}
			else
			{
				response = ifrm.contentDocument.document.body ? ifrm.contentDocument.document.body.innerHTML : "";
			}

			if (/(<pre)?({.+})(<\/pre>)+/.test(response) || /(<pre)?({.+})/.test(response))
			{
				var j = RegExp["$2"];
				var data = JSON.parse(j);

				var code = data[ERR_CODE];
				switch(code){
				case E_SESSIONTIMEOUT:
					showAlert(label.loginTimeout, function(choose){
						stateman.go("login");
					});
					break;
				case E_UNAUTH:
					stateman.go("login");
					break;
				default:
					break;
				}
			}

			callBack(data);
		}
		catch(ex)
		{
			callBack(data);
		}
	};

	/* check for dns redirect */
	this.pageRedirect = function()
	{
		var lanLogin = BROWSER.lan;
		var domain = ROUTER.domain;
		var url = window.location.href;

		if (false == /^((http:\/\/)*(\d{1,3}\.){3}\d{1,3})/g.test(url)
			&& lanLogin
			&& url.indexOf(domain) < 0)
		{
			return true
		}

		return false;
	};

	this.pageOnload = function()
	{
		/* 处理DNS重定向 */
		if(pageRedirect()){
			window.location.href = "http://" + ROUTER.domain;
			return;
		};

		getPageStyle();

		var lang = ROUTER.lang;
		var links = [];

		var scripts = [{tag:"script", url:"/luci-static/dynaform/vendor.js?_=20170809165512"},
					   {tag:"script", url:"/luci-static/lib/libs.js?_=20170809165512"}];

		var delayscripts = [{tag:"script", url:"/luci-static/lib/ajax.js?_=20170809165512"},
							{tag:"script", url:"/luci-static/dynaform/routing.js?_=20170809165512"},
							{tag:"script", url:"/luci-static/dynaform/error.js?_=20170809165512"},
							{tag:"script", url:"/luci-static/dynaform/" + lang + ".js?_=20170809165512"},
							{tag:"script", url:"/luci-static/dynaform/verify.js?_=20170809165512"}];

		var prelinks = [];

		var prescripts = [{tag:"script", url:"/luci-static/lib/jquery.min.js?_=20170809165512"},
                          {tag:"script", url:"/luci-static/lib/stateman.min.js?_=20170809165512"},
						  {tag:"script", url:"/luci-static/lib/json.min.js?_=20170809165512"}];

		if (OS.mobile){
			prescripts.splice(0, 0, {tag:"script", url:"/luci-static/lib/flexible.min.js?_=20170809165512"});
			prescripts.push({tag:"script", url:"/luci-static/dynaform/h5.js?_=20170809165512"});
			prelinks.push({tag:"link", url:"/luci-static/dynaform/h5.css?_=20170809165512"});

			var i18nStyles = {
				"zh-cn":[],
				"en-us":[{tag:"link", url:"/luci-static/dynaform/h5-en-us.css?_=20170809165512"}]
			};

			for(var i = 0; i < i18nStyles[lang].length; i++){
				prelinks.push(i18nStyles[lang][i]);
			}
		}else{
			prelinks.push({tag:"link", url:"/luci-static/dynaform/pc.css?_=20170809165512"});
			prescripts.push({tag:"script", url:"/luci-static/dynaform/pc.js?_=20170809165512"});

			var i18nStyles = {
				"zh-cn":[],
				"en-us":[{tag:"link", url:"/luci-static/dynaform/pc-en-us.css?_=20170809165512"}]
			};

			for(var i = 0; i < i18nStyles[lang].length; i++){
				prelinks.push(i18nStyles[lang][i]);
			}

			if (window.screen.width >= 1920) // 适配分辨率1080p时加载
			{
				prelinks.push({tag:"link", url:"/luci-static/dynaform/style_1080p.css?_=20170809165512"});
			}

			if (isIE){	// 为兼容IE额外加的库
				prescripts.push({tag:"script", url:"/luci-static/lib/respond.min.js?_=20170809165512"});

				if (!isIENormal){
					prelinks.push({tag:"link", url:"/luci-static/dynaform/ie.css?_=20170809165512"});
				}
			}
		}

		this.loadExternResource({scripts:prescripts, links:prelinks, callBack:function(){
			this.loadExternResource({scripts:delayscripts, callBack:function()
			{
				$Init();

				if (OS.mobile){
					pageStyleInit("h5");
					landscapeHdInit();
				}else{
					pageStyleInit("pc");

					$("i.help-back").click(function(){
						$("#Help").removeClass("help-show");
					});

					var helpScroll = new NiceScroll("HelpInfo");
					helpScroll.scrollBarSet({zIndex:1021});
					helpScroll.scrollTipSet({background:"#939393", opacity:"0.2"});
					helpScroll.init();
				}

				/* 注册相应处理函数 */
				$.setexternJSP(replaceJSP);
				$.setExternPageHandle(loadPageHandleBg);

				this.loadExternResource({scripts:scripts, links:links});
				this.localSgInit();
				this.compatibleShow();

				stateman.start();
			}});
		}});

		document.oncontextmenu = function(event){
			return false;
		};

		if (isIESix)
		{
			try{document.execCommand('BackgroundImageCache', false, true);}catch(e){};
		}
	};

	/* 异步加载资源 */
	this.loadExternResource = function(obj)
	{
		var elem, links, scripts, callBack, hasReadyState;
		var head = document.getElementsByTagName("head")[0];
		var ObjOrg = {links:null, scripts:null, callBack:null};

		/* 初始化参数列表 */
		for(var prop in obj)
		{
			ObjOrg[prop] = obj[prop];
		}

		links = ObjOrg.links;
		scripts = ObjOrg.scripts;
		callBack = ObjOrg.callBack;

		/* 加载CSS */
		if (links != undefined)
		{
			for (var i in links)
			{
				elem = document.createElement("link");
				elem.rel = "stylesheet";
				elem.href = links[i].url;
				head.appendChild(elem);
			}
		}

		/* 加载js */
		if (scripts != undefined)
		{
			var load, loadHandle, loadCallBack;

			elem = document.createElement("script");
			elem.type = "text/javascript";

			if (callBack != undefined)
			{
				hasReadyState = (elem.readyState != undefined);
				loadCallBack = function(index)
				{
					scripts[index].loadState = true;

					for (var j in scripts)
					{
						if (false == scripts[j].loadState)
						{
							return;
						}
					}

					callBack();
				};

				for (var i in scripts)
				{
					scripts[i].loadState = false;
				}
			}

			for (var i in scripts)
			{
				elem = document.createElement("script");
				elem.type = "text/javascript";

					if (callBack != undefined)
					{
						if (hasReadyState)
						{
							elem.onreadystatechange = (function(index){
								return function(){
									if (this.readyState == "loaded" || this.readyState == "complete")
									{
										this.onreadystatechange = null;
										loadCallBack(index);
									}
								};
							})(i);
						}
						else
						{
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
}
function Style()
{
	this.disableCol = "#b2b2b2";

	/* set the element styles with the styles */
	this.setStyle = function (ele, styles)
	{
		if (ele == null || styles == null || ele.nodeType != 1)
		{
			return;
		}
		
		for (var property in styles)
		{
			try
			{
				ele.style[property] = styles[property];
			}catch(ex){}
		}
	};
	
	/* get the default style of the element*/
	this.getNodeDefaultView = function(element, cssProperty)
	{
		var dv = null;
		if (!(element))
		{
			return null;
		}

		try{
			if (element.currentStyle)
			{
				dv = element.currentStyle;
			}
			else
			{
				dv = document.defaultView.getComputedStyle(element, null);
			}

			if (cssProperty != undefined)
			{
				return dv[cssProperty];
			}
			else
			{
				return dv;
			}
		}catch(ex){}
	};
}
function LocalStorageSD()
{
	try
	{
		if (null == this.sessionStorage)
		{
			this.sessionLS = {
				file_name:"user_data_default_SD",
				dom:null,
				init:function()
				{
					var dom = document.createElement('input');

					dom.type = "hidden";
					dom.addBehavior("#default#userData");
					document.body.appendChild(dom);
					dom.save(this.file_name);
					this.dom = dom;
				},
				setItem:function(k, v)
				{
					this.dom.setAttribute(k,v);
					this.dom.save(this.file_name);
				}, 
				getItem:function(k)
				{
					this.dom.load(this.file_name); 
					return this.dom.getAttribute(k); 
				}, 
				removeItem:function(k)
				{
					this.dom.removeAttribute(k);
					this.dom.save(this.file_name);
				},
				setExpire:function(timeSecond)
				{
				   var now = new Date();

				   now = new Date(now.getTime() + timeSecond);
				   this.dom.load(this.file_name);
				   this.dom.expires = now.toUTCString();
				   this.dom.save(this.file_name);
				}
			};
		}
		else
		{
			this.sessionLS = sessionStorage;
		}
	}catch(ex){};
}
function Explorer()
{
	this.isIE = false;
	this.isIESix = false;
	this.isIESeven = false;
	this.isIENormal = false;
	this.isIETenLess = false;
	this.explorerInfo = navigator.userAgent;

	this.getIEInfo = function(){
		isIE = /msie ((\d+\.)+\d+)/i.test(explorerInfo)?(document.mode || RegExp["$1"]):false;

		if (isIE != false)
		{
			if (isIE <= 6)
			{
				this.isIESix = true;
			}
			else if (isIE == 7)
			{
				this.isIESeven = true;
			}
			else if (isIE >= 9)
			{
				this.isIENormal = true;
			}

			if (isIE <= 10)
			{
				this.isIETenLess = true;
			}

			this.isIE = true;
		}
	};

	this.compatibleShow = function(){
		if (isIE && false == this.isIENormal){
			var closeKey = "ieTipClosed";

			if (document.cookie.indexOf(closeKey) >= 0){
				return;
			}

			alert(label.IETip);
			document.cookie = closeKey + "=true";
		}
	};

	this.getIEInfo();	
}
function Tool()
{
	Style.call(this);
	
	/* get element by id */
	this.id = function(idStr)
	{
		if (idStr != undefined)
		{
			return document.getElementById(idStr);
		}
	};
	
	/* create element */
	this.el = function(str)
	{
		try
		{
			return document.createElement(str);
		}catch(ex){return null;}
	};
	
	/* replace {%....%} to realize multi languages */
	this.replaceJSP = function(str)
	{
		var matches = null, strRepace;
		var tagL = "{%", tagR = "%}";
		var rp = /{%(\w+)\.(\w+)%}/i;
		
		matches = rp.exec(str);
		try
		{
			while(matches != null)
			{				
				strRepace = language[matches[1]][matches[2]];
				str = str.replace(tagL + matches[1] + "." + matches[2] + tagR, strRepace);
				matches = rp.exec(str);
			}
		}catch(ex){}
		return str;
	};
	
	/* get the offsetLeft and offsetTop to the border of the container(default is browser) */
	this.getoffset = function(obj, container)
	{
		var tempObj = obj;
		var relPo = {
			top:0,
			left:0
		};

		while(true)
		{
			if (tempObj == container)
			{
				break;
			}

			relPo.left += parseInt(tempObj.offsetLeft);
			relPo.top += parseInt(tempObj.offsetTop);
			tempObj = tempObj.offsetParent;
		}

		return relPo;
	};
	
	this.attachEvnt = function(target, event, handle)
	{
		if (event.indexOf("on") == 0)
		{
			event = event.substring(2);
		}

		if (document.body.attachEvent)
		{
			target.attachEvent("on" + event, handle);
		}
		else
		{
			target.addEventListener(event, handle, false);
		}
	};

	this.detachEvnt = function(target, event, handle){
		if (event.indexOf("on") == 0)
		{
			event = event.substring(2);
		}

		if (document.body.attachEvent)
		{
			target.detachEvent("on" + event, handle);
		}
		else
		{
			target.removeEventListener(event, handle, false);
		}
	};

	/* stop propagation of event */
	this.stopProp = function (event)
	{
		event = event || window.event;
		if (event.stopPropagation)
		{
			event.stopPropagation();
		}
		else
		{
			event.cancelBubble = true;
		}
	};
	
	/* prevent defaut operation of event */
	this.eventPreventDefault = function (event)
	{
		event = event || window.event;
		if(event.preventDefault)
		{
			event.preventDefault();
		}
		else
		{
			event.returnValue = false;
		}
	};

	/* clear selection produced width mouse move */
	this.clearSelection = function ()
	{
		window.getSelection ? window.getSelection().removeAllRanges() : document.selection.empty();
	};

	/* 设置dom上range的光标位置 */
	this.setDomCursorPos = function (dom, pos)
	{ 
		if (dom.setSelectionRange)
		{
			dom.focus();
			dom.setSelectionRange(pos, pos);
		}
		else if (dom.createTextRange)
		{
			var range = dom.createTextRange()
			range.collapse(true);
			range.moveEnd('character', pos);
			range.moveStart('character', pos);
			range.select();
		}
	}

	/* get the pos of the mouse width the event */
	this.getMousePos = function (event)
	{
		event = event || window.event;
		var doc = document;
		var pos = (event.pageX || event.pageY) ? {x:event.pageX,y:event.pageY}:
				{x:event.clientX + doc.documentElement.scrollLeft - doc.documentElement.clientLeft,
				 y:event.clientY + doc.documentElement.scrollTop - doc.documentElement.clientTop};
		return pos;
	};
	
	/* 判断对象是否是数组 */
	this.isArray = function (obj)
	{
		return Object.prototype.toString.call(obj) === '[object Array]';
	};
	
	/* create up down */
	this.upDown = function (con, taId, classNameUp, classNameDown, callBack)
	{
		if (classNameUp == undefined || classNameDown == undefined)
		{
			return;
		}
		
		var lbl = this.el("label");
		
		lbl.className = classNameDown;
		lbl.onclick = function(){
			$("#"+taId).slideToggle("normal", function(){
				lbl.className = (lbl.className == classNameUp?classNameDown:classNameUp);
				if (callBack)
				{
					try
					{
						callBack();
					}catch(ex){}
				}
			});
		};
		con.appendChild(lbl);
		
		return lbl;
	};
	
	this.arrowUpDown = function (con, taId, callBack){
		this.upDown(con, taId, "arrowUp", "arrowDown", callBack);
	};
	
	/* 获取dom节点下指定类型的节点，index可选, filter:"input checkbox" */
	this.getChildNode = function(parent, filter, index){
		var childs = parent.childNodes;
		var nodes = [], count = 0, tempNode;
		var paras = filter.split(" ");
		var nodeName = paras[0], type = paras[1];

		for(var i = 0, len = childs.length;i < len; i++)
		{
			tempNode = childs[i];
			if (tempNode.nodeType == 1 && tempNode.tagName.toLowerCase() == nodeName)
			{
				if (type != undefined && tempNode["type"] == type)
				{
					nodes[count] = tempNode;
					count++;
				}
				else if (type == undefined)
				{
					nodes[count] = tempNode;
					count++;
				}
			}
		}
		if (index != undefined)
		{
			return nodes[index];
		}

		return nodes[0];
	};

	/* 检查节点是否可见 */
	this.checkInHorize = function(ta){
		var node = ta;
		while(node != null && node.nodeName.toUpperCase() != "HTML")
		{
			if (this.getNodeDefaultView(node, "visibility") == "hidden" ||
				this.getNodeDefaultView(node, "display") == "none")
			{
				return false;
			}
			node = node.parentNode;
		}

		return true;
	};

	this.setUrlHash = function(key, value)
	{
		var strH, strT, pos, tag ="";
		var url = location.href;
		var hash = location.hash;

		if (key == undefined || 
			value == undefined ||
			key.length == 0)
		{
			return;
		}
		
		if (hash.length != 0)
		{
			pos = hash.indexOf(key);
			if (pos >= 0)
			{
				strH = hash.substring(0, pos);
				strT = hash.substring(pos);
				pos = strT.indexOf("#");
				if (pos > 0)
				{
					strT = strT.substring(pos);
					hash = strH + key + "=" + value + strT;
				}
				else
				{
					hash = strH + key + "=" + value;
				}
			}
			else
			{
				if (hash.substring(hash.length - 1) != "#")
				{
					tag = "#";
				}
				hash += (tag + key + "=" + value);
			}

			location.href = url.substring(0, url.indexOf("#")) + hash;
		}
		else
		{
			if (url.lastIndexOf("#") == (url.length - 1))
			{
				location.href += (key + "=" + value);
			}
			else
			{
				location.href += ("#" + key + "=" + value);
			}
		}
	};

	this.getUrlHash = function(key)
	{
		var hash = location.hash;
		var pos = hash.indexOf(key);
		var strArr, tempArr, value = "";

		if (pos > 0)
		{
			strArr = hash.substring(1).split("#");
			for(var index in strArr)
			{
				tempArr = strArr[index].split("=");
				if (tempArr[0] == key)
				{
					value = tempArr[1];
					break;
				}
			}
		}

		return value;
	};

	this.changeUrlHash = function(str)
	{
		var url = location.href;
		var pos = url.indexOf("#");
		
		if (str == undefined)
		{
			return;
		}

		if (pos > 0)
		{
			location.href = url.substring(0, pos + 1) + str;
		}
		else
		{
			location.href = url + "#" +str;
		}
	};

	/* 设置输入框的光标的位置 */
	this.setInputCursor = function(input){
		var len = input.value.length;

		this.setDomCursorPos(input, len);
	};

	/* 获取字符串的长度，采用UTF-8编码，汉字占3个字符 */
	this.getCNStrLen = function(str)
	{
		return str.replace(/[^\x00-\xFF]/g, "xxx").length;
	};

	/* 截取字符串，最大长度为maxNum个字节 */
	this.getStrInMaxByte = function(str, maxNum){
		var bytes = 0;
		for (var i = 0; i < str.length; i++){
			if (/[\x00-\xFF]/g.test(str.charAt(i))){
				bytes += 1;
			}else{
				bytes += 3;		// utf-8编码的中文为3个字节
			}

			if (bytes > maxNum){
				return str.substring(0, i);
			}else if (bytes == maxNum){
				return str.substring(0, i+1);
			}
		}

		return str;
	};

	/* 获取字符串在HTML中的长度 */
	this.getCNStrHTMLLen = function(str){
		return str.replace(/[^\x00-\xFF]/g, "xx").length;
	};

	/* 截取字符串，如果超过maxNum则以...结束 */
	this.getStrInMax = function(value, maxNum){
		var str = "", strTemp, j = 0;
		var tmpStr = value.replace(/[A-Z]/g, "xx");

		if (getCNStrHTMLLen(tmpStr) <= maxNum)
		{
			return value;
		}

		for(var count = 1; count <= maxNum; count++)
		{
			strTemp = value.charAt(j);
			if (strTemp == "")
			{
				break;
			}

			if (getCNStrHTMLLen(strTemp) == 2 || /[A-Z]/g.test(strTemp) == true)
			{
				count++;
				str += strTemp;
				beCut = true;
			}
			else
			{
				str += strTemp;
			}

			j++;
		}
		return str + "...";
	};

	this.netSpeedTrans = function(speed){
		var kSpeed = 1024;
		var mSpeed = kSpeed * 1024;
		var gSpeed = mSpeed * 1024;

		speed = parseInt(speed, 10);
		if (speed >= gSpeed){
			speed = (speed/gSpeed).toFixed(0) + "GB/s";
		}
		else if (speed >= mSpeed){
			speed = (speed/mSpeed).toFixed(0) + "MB/s";
		}
		else if (speed >= kSpeed){
			speed = (speed/kSpeed).toFixed(0) + "KB/s";
		}
		else{
			speed = speed.toFixed(0) + "B/s";
		}

		return speed.toString();
	};

	this.timeTrans = function(total){
		var seconds = parseInt(total, 10);
		var day = parseInt(seconds/86400);
		var hour = parseInt((seconds%86400)/3600);
		var minute = parseInt((seconds%3600)/60);
		var second = parseInt(seconds%60);

		var timeStr = "";
		if (day > 0){
			timeStr += day + label.day;
		}

		if (hour > 0){
			timeStr += hour + label.hour;
		}

		if (minute > 0){
			timeStr += minute + label.minute;
		}

		if (second >= 0){
			timeStr += second + label.second;
		}

		return timeStr;
	};

	this.max = function(){
		var m = Number.NEGATIVE_INFINITY;
		for (var i = 0; i < arguments.length; i++)
		{
			if (arguments[i] > m) m = arguments[i];
		}

		return m;
	};

	this.EncodeURLIMG = document.createElement("img");

	/* 对多字节字符编码 */
	this.escapeDBC = function(s)
	{
		var img = this.EncodeURLIMG;

		if (!s) 
		{
			return "";
		}

		if (window.ActiveXObject)
		{
			/* 如果是IE, 使用vbscript */
			execScript('SetLocale "zh-cn"', 'vbscript');
			return s.replace(/[\d\D]/g, function($0) {
				window.vbsval = "";
				execScript('window.vbsval=Hex(Asc("' + $0 + '"))', "vbscript");
				return "%" + window.vbsval.slice(0,2) + "%" + window.vbsval.slice(-2);
			});
		}

		/* 其它浏览器利用浏览器对请求地址自动编码的特性 */
		img.src = "nothing.png?separator=" + s;

		return img.src.split("?separator=").pop();
	};

	/* 对URL的参数进行GBK或UTF-8编码 */
	this.encodeURL = function(s)
	{
		return encodeURIComponent(s);

		/* 把 多字节字符 与 单字节字符 分开，分别使用 escapeDBC 和 encodeURIComponent 进行编码 */
		/*return s.replace(/([^\x00-\xff]+)|([\x00-\xff]+)/g, function($0, $1, $2) {
			return escapeDBC($1) + encodeURIComponent($2 || '');
		});*/
	};

	this.doNothing = function()
	{
		return true;
	};

	/* 转换特殊的HTML标记 */
	this.htmlEscape = function(str)
	{
		var escapseStr = str;

		if (undefined != escapseStr)
		{
			escapseStr = escapseStr.toString().replace(/[<>&"]/g, function(match){
				switch(match)
				{
				case "<":
					return "&lt;";
				case ">":
					return "&gt;";
				case "&":
					return "&amp;";
				case "\"":
					return "&quot;";
				}
			});
		}

		return escapseStr;
	};
	
	/* 模拟鼠标点击操作 */
	this.simulateMouseC = function (target)
	{
		if (true == isIE && false == isIENormal)
		{
			simulateMouseC = function(target){
				var event = document.createEventObject();

				event.sceenX = 100;
				event.sceenY = 0;
				event.clientX = 0;
				event.clientY = 0;
				event.ctrlKey = false;
				event.altKey = false;
				event.shiftKey = false;
				event.button = 0;

				target.fireEvent("onclick", event);
			};
		}
		else
		{
			simulateMouseC = function(){};
		}

		simulateMouseC(target);
	};
}
function ShowTips()
{
	this.showCover = function(){	
		$("#Pop").show();
		$("#Cover").fadeIn("fast");
	};

	this.closeCover = function(){
		$("#Pop").hide();
		$("#Cover").fadeOut("fast");
	};

	/* 显示正在loading的状态 */
	this.showLoading = function(noteStr){
		var loadingCon =
					'<div class="loading">' + 
						'<div class="outer-circle"><div class="inside-circle"><i class="circle"></i></div></div>' + 
						'<p class="loading-tip">' + noteStr + '</p>' + 
					'</div>';

		$("#Cover").fadeIn("fast");
		$("#Pop").empty().append(loadingCon).show();
	};

	/* 关闭正在loading的状态 */
	this.closeLoading = function(){
		closeCover();
	};

	/* 用于显示提示信息 */
	this.showNote = function(noteStr){
		$(".err-note").show();
		$(".err-note").children(".note-str").html(noteStr);
	};

	this.closeNote = function(){
		$(".err-note").hide();
	};

	this.showAlert = function(noteStr, callback){
		var loadingCon =
					'<div class="alert">' +
						'<p class="alert-title">' + label.alertTip + '</p>' + 
						'<p class="alert-tip">' + noteStr + '</p>' +
						'<div class="alert-btn-con">'+
							'<input class="alert-btn" type="button" value="' + btn.ok + '" />' +
						'</div>'+
					'</div>';

		$("#Cover").fadeIn("fast");
		$("#Pop").empty().append(loadingCon).show();
		$("input.alert-btn").click(function(){
			closeAlert(callback);
		});
	};

	this.closeAlert = function(callback){
		closeCover();
		callback && callback();
	};

	this.showConfirm = function(noteStr, callback){
		var loadingCon =
					'<div class="alert">' +
						'<p class="alert-title">' + label.alertTip + '</p>' + 
						'<p class="alert-tip">' + noteStr + '</p>' +
						'<div class="alert-btn-con">'+
							'<input class="confirm-btn confirm-btn-l" type="button" value="' + btn.cancel + '" />' +
							'<input class="confirm-btn confirm-btn-r" type="button" value="' + btn.ok + '" />' +
						'</div>'+
					'</div>';

		$("#Cover").fadeIn("fast");
		$("#Pop").empty().append(loadingCon).show();
		$("input.confirm-btn-l").click(function(){
			closeConfirm(function(){
				callback && callback(false);
			});
		});
		$("input.confirm-btn-r").click(function(){
			closeConfirm(function(){
				callback && callback(true);
			});
		});
	};

	this.closeConfirm = function(callback){
		closeCover();
		callback && callback();
	};

	this.progressBarTimer = null;
	this.showProgressBar = function(title, tip, time, callback){
		var loadingCon =
					'<div class="alert progress-bar-con">' +
						'<p class="alert-title progress-title">' + title + '</p>' +
						'<div class="progress-bar">' +
							'<p class="percent"><label class="percent">0%</label></p>' +
							'<p class="percent"><i class="icon_position"></i></p>' +
							'<div class="bar"><p class="percent progress"></p></div>' +
						'</div>' + 
						'<p class="progress-bar-tip">' + tip + '</p>' +
					'</div>';

		$("#Cover").fadeIn("fast");
		$("#Pop").empty().append(loadingCon).show();

		this.refreshBar = function(count){
			var percent = count + "%";
			var barWidth = $(".progress-bar").width();

			$("p.percent").width(percent);
			$("label.percent").text(percent);

			var textWidth = $("i.icon_position").width() / 2;
			var offsetText = barWidth * count / 100 - textWidth;
			if (offsetText > textWidth){
				offsetText = textWidth;
			}
			$("label.percent").css("left", offsetText + "px");

			var cursorWidth = $("i.icon_position").width() / 2;
			var offset = barWidth * count / 100 - cursorWidth;
			if (offset > cursorWidth){
				offset = cursorWidth;
			}

			$("i.icon_position").css("left", offset + "px");

			if (count >= 100){
				this.count = 0;
				clearInterval(progressBarTimer);
				callback && callback();
				return;
			}
		};

		this.progressBarPercent = 0;
		this.refreshBar(this.progressBarPercent++);

		clearInterval(this.progressBarTimer);
		this.progressBarTimer = $.setInterval(function(){
			this.refreshBar(this.progressBarPercent++);
		}, time / 100);
	};
}

function Phone()
{
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
		app:			false,	/* page is loaded in PHICOMM APP webview or not */

		checkDeviceMode:function ()
		{
			var pl = navigator.platform;
			var ua = navigator.userAgent;

			this.app = (ua.indexOf("Phicomm") >= 0);

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
		},
		checkDeviceType:function()
		{
			if (this.app)
			{
				this.deviceType = "app";
			}
			else if (this.mobile)
			{
				this.deviceType = "h5";
			}
			else
			{
				this.deviceType = "pc";
			}
			return;
		}
	};

	OS.checkDeviceMode();
	OS.checkDeviceType();
}

/* 检测LAN是否可以连接DUT */
function LanDetect()
{
	this.lanDetectSuccess = false;
	this.LAN_DETECT_TIME = 2000;
	this.lanDetectTimeHd = null;

	this.lanDetectHandle = function(callBack)
	{
		clearTimeout(this.lanDetectTimeHd);

		if (false == $.result.timeout && false == this.lanDetectSuccess){
			this.lanDetectSuccess = true;
			callBack();
		}
	}

	this.lanDetecting = function(callBack)
	{
		$.detect(function(){
			lanDetectHandle(callBack);
		});

		this.lanDetectTimeHd = $.setTimeout(function(){
			lanDetecting(callBack);
		}, this.LAN_DETECT_TIME);
	}
}

function Api()
{
	this.K_METHOD = "method";
	this.K_MODULE = "module";

	this.apiGet = function(data, callback){
		var para = {};
		para[this.K_METHOD] = "get";
		para[this.K_MODULE] = data;

		$.sendAjax("/data", para, callback, "post");
	};

	this.apiSet = function(data, callback){
		var para = {};
		para[this.K_METHOD] = "set";
		para[this.K_MODULE] = data;

		$.sendAjax("/data", para, callback, "post");
	};

	this.apiAdd = function(data, callback){
		var para = {};
		para[this.K_METHOD] = "add";
		para[this.K_MODULE] = data;

		$.sendAjax("/data", para, callback, "post");
	};

	this.apiDel = function(data, callback){
		var para = {};
		para[this.K_METHOD] = "del";
		para[this.K_MODULE] = data;

		$.sendAjax("/data", para, callback, "post");
	};

	this._security = function(action, data, callback){
		var tmp = {};

		tmp[K_METHOD] = "set";
		tmp[K_MODULE] = {};
		tmp[K_MODULE]["security"] = {};
		tmp[K_MODULE]["security"][action] = data;
		tmp._deviceType = OS.deviceType;

		var para = JSON.stringify(
			tmp,
			function(key, value) {
				if (typeof(value) === "string") {
					return encodeURIComponent(value);
				}
				return value;
			}
		);

		var href = location.href;
		var index = href.indexOf("#");
		var url = href.substring(0, index) + "/";

		jQuery.ajax({
			'url': url,
			'data':	para,
			'type': "post",
			'contentType': 'application/json',
			'success': callback
		});
	};

	this.apiLogin = function(data, callback){
		var action = "login";
		this._security(action, data, function(result){
			var code = result[ERR_CODE];
			if (E_NONE == code){
				$.setSession(result[K_MODULE]["security"][action].stok);
			}

			callback && callback(result);
		});
	};

	this.apiLogout = function(callback){
		var data = {};
		data[$.sessionKey] = $.session;

		this._security("logout", data, callback);
	};

	this.apiRegister = function(data, callback){
		var action = "register";
		this._security(action, data, function(result){
			var code = result[ERR_CODE];
			if (E_NONE == code){
				$.setSession(result[K_MODULE]["security"][action].stok);
			}

			callback && callback(result);
		});
	};

	this.apiModify = function(data, callback){
		this._security("modify", data, callback);
	};
}

(function(){
	Phone.call(window);
	Tool.call(window);
	PageFunc.call(window);
	Explorer.call(window);
	LocalStorageSD.call(window);
	ShowTips.call(window);
	LanDetect.call(window);
	Api.call(window);
})();
