function Basic()
{
	this.w = window;
	this.routerAlive = false;
	this.head = document.getElementsByTagName("head")[0];
	this.d = document;
	this.local = (location.protocol == "file:");
	this.isIE = (navigator.userAgent.indexOf("IE") >= 0);
	this.domainUrl = "http://p.to";
	this.time = 1000;
	this.explorerTag = 0;
	this.UA = "h5";
	this.httpTag = "http://";
	this.ajaxAsyn = true;

	this.isArray = function(obj)
	{
		return Object.prototype.toString.call(obj) === '[object Array]';
	};

	this.getExplorer = function ()
	{
		var nv = navigator.userAgent;
		
		if (nv.indexOf("IE 6.0") > 0)
		{
			this.explorerTag = 6;
		}
		else if (nv.indexOf("IE 7.0") > 0)
		{
			this.explorerTag = 7;
		}

		if (OS.mobile)
		{
			this.UA = "h5";
		}
		else
		{
			this.UA = "pc";
		}
	};

	this.transText = function(text)
	{
		if (text.length > 0)
		{
			text = text.substring(text.indexOf("\r\n") + 2);
			try
			{
				return eval("("+text+")");
			}catch(ex){return ""}
		}
	};

	this.id = function (idStr)
	{
		return document.getElementById(idStr);
	};

	this.changeDomain = function(domain)
	{
		var urlHeaderTag = this.httpTag;
		this.domainUrl = domain.indexOf(urlHeaderTag) >= 0?(domain):(urlHeaderTag+domain);
	};

	this.initUrl = function ()
	{
		if (!this.local)
		{
			var url = location.href;
			var urlMatch = url.match(/[a-z0-9][-a-z0-9]{0,62}(\.[a-z0-9][-a-z0-9]{0,62})+\.?/i);

			if (null != urlMatch){
				this.domainUrl = this.httpTag + urlMatch[0];
			}
		}
	};

	this.objInitNull = function (obj)
	{
		for(var property in obj)
		{
			if (typeof obj[property] == "object")	//是对象
			{
				this.arguments.callee(obj[property]);
			}
			else	//不是对象,
			{
				obj[property] = "";
			}
		}
	};

	this.objSet = function(obj, val)
	{
		if (this.isArray(val))
		{
			var n = 0;
			for(var property in obj)
			{
				obj[property] = val[n++];
			}
		}
		else
		{
			for(var property in obj)
			{
				obj[property] = val;
			}
		}
	};

	this.objCopy = function(target, srcObj)
	{
		var temp;
		for(var porperty in target)
		{
			temp = srcObj[porperty];
			if (temp != undefined)
			{
				target[porperty] = temp;
			}
		}
	};

	this.encodePara = function(val)
	{
		val = encodeURL(val.toString());

		return val;
	};
}

function WebAjax()
{
	this.local = (location.protocol == "file:");
	this.isIE = (navigator.userAgent.indexOf("IE") >= 0);
	this.ajaxTimeout = 2000;
	this.session = "";
	this.sessionKey = "stok";
	this.externDataParseFunc = new Function();

	this.result = 
	{
		errorno:0,
		data:"",
		timeout:true
	};

	this.initResult = function (result)
	{
		this.result.errorno = 0;
		this.result.data = "";
		this.result.timeout = true;
	};
	
	this.initSession = function()
	{
		var stok = "";

		try{
			stok = sessionLS.getItem(this.sessionKey) || "";
		}catch(e){}

		this.session = sessionLS.getItem(this.sessionKey);
	};
	
	this.setSession = function(session)
	{
		this.session = session;

		try{
			sessionLS.setItem(this.sessionKey, session);
		}catch(e){}
	}

	this.setDataParseFunc = function(func)
	{
		this.externDataParseFunc = func;
	};

	this.changeAsynTime = function(time)
	{
		this.ajaxTimeout = time;	
	};

	this.getValueFromUrl = function(url, str)
	{
		var value = "", pos;

		str += "=";
		pos = url.indexOf(str);
		if (pos >= 0)
		{
			var substr = url.substring(pos+str.length);
			pos = substr.indexOf("&");
			pos = pos > 0?pos:substr.length;
			value = substr.substring(0, pos);
		}

		return value;
	};

	this.orgURL = function(url)
	{
		var href = location.href;

		var index = href.indexOf("#");
		if (index >= 0)
		{
			if ($.session && $.session.length != 0)
			{
				url = href.substring(0, index) + "/stok=" + encodeURIComponent($.session) + url;
			}else{
				url = href.substring(0, index) + url;
			}
		}

		return url;
	};

	this.request = function(url, data, method, asyn, callback, timeout, name, password)
	{
		var xhr = window.ActiveXObject?new ActiveXObject("Microsoft.XMLHTTP"):new XMLHttpRequest();
		var responseText, setTime, asynTime, isAjaxTimeout = false;
		var thisObj = this, response = false;

		this.initResult(thisObj.result);

		function getHandleCode(text)
		{
			var handleCode, data, obj;

			try 
			{
				obj = JSON.parse(text,
					function(k, v){
						var val = v;

						if (typeof val === "string") 
						{
							try
							{
								val = decodeURIComponent(val);
							}catch(ex){}
						}

						return val;
					}
				);
			} 
			catch(ex)
			{
				obj = null;
			}

			if (obj == null)
			{
				handleCode = E_NONE;
				data = text;
			}
			else
			{
				handleCode = obj[ERR_CODE];
				data = obj.data;
			}

			return [handleCode, data];
		}

		xhr.onreadystatechange = function ()
		{
			if (true == isAjaxTimeout)
			{		
				return;
			}

			if ((xhr.readyState == 4) && (true === $.local || xhr.status >= 100))
			{
				response = true;
				thisObj.result.timeout = false;
				responseText = xhr.responseText;
				if (responseText)
				{
					thisObj.result.data = responseText;
				}

				var relArr = getHandleCode(responseText);

				thisObj.result.errorno = relArr[0];
				thisObj.result.data = relArr[1];

				/* 判断是否有回调函数 */
				if (callback != undefined)
				{
					callback(thisObj.result);
				}

				return true;
			}
		};

		try
		{
			if ((name != undefined) && (password != undefined))
			{
				xhr.open(method, url, asyn, name, password);
			}
			else
			{
				xhr.open(method, url, asyn);
			}
		
			//if (this.isIE == true)	// 禁止缓存页面
			{
				xhr.setRequestHeader("If-Modified-Since","0");
			}

			if (data != undefined)
			{
				xhr.send(data);
			}
			else
			{
				xhr.send(null);
			}
		}catch(ex){}
	};
}

function Load()
{
	Basic.call(this);
	WebAjax.call(this);
	this.asyn = true;
	this.syn = false;
	this.detectTime = 1000;
	this.div = document.createElement("div");
	this.externResizefunc = new Function();
	this.externJSP = new Function();
	this.externLoading = new Function();
	this.externPageHandle = new Function();
	this.pageTickArray = [];
	this.pageCycleArray = [];
	this.scriptArray = [];
	this.unAuthCode = 401;
	this.httpOK = 200;

	this.setTimeout = function (func, time)
	{
		var handle = window.setTimeout(func, time);

		this.pageTickArray.push(handle);

		return handle;
	};
	this.setInterval = function (func, time)
	{
		var handle = window.setInterval(func, time);

		this.pageCycleArray.push(handle);

		return handle;
	};
	function empty(node)
	{
		/* for the bug of MSIE 6.0 */
		if (node)
		{
			node.innerHTML = "";
			return;
		}
	};

	this.addScript = function (text)
	{
		if (text && /\S/.test(text))
		{
			var script = this.d.createElement("script");
			script.type = "text/javascript";

			if (script.text === undefined)
			{
				script.appendChild(this.d.createTextNode(text));
			}
			else
			{
				script.text = text;
			}
			this.head.insertBefore(script, this.head.firstChild);
			this.head.removeChild(script);
		}
	};

	this.getNodeArray = function (nodes, callBack)
	{
		var pArray = [];
		for (var i =0, j = nodes.length; i < j; i++)
		{
			pArray[i] = nodes[i];
		}
		callBack(pArray);
	};

	this.addDomNode = function(container, data, clearTimer)
	{	
		var thisObj = this;
		this.div.innerHTML = "div" + data;
		this.div.removeChild(this.div.firstChild);
		this.getNodeArray(this.div.childNodes, 
		function (nodeArray)
		{
			empty(container);
			if (clearTimer)
			{
				for(var i = 0, j = thisObj.pageTickArray.length; i < j; i++)
				{
					try
					{
						window.clearTimeout(thisObj.pageTickArray.shift());
					}catch(ex){}
				}

				for(var i = 0, j = thisObj.pageCycleArray.length; i < j; i++)
				{
					try
					{
						window.clearTimeout(thisObj.pageCycleArray.shift());
					}catch(ex){}
				}
			}

			var scriptArray = [];
			for(var i =0, j = nodeArray.length; i < j; i++)
			{
				if ((nodeArray[i].nodeType == 1)&&(nodeArray[i].nodeName.toLowerCase() === "script"))
				{
					scriptArray.push(nodeArray[i]);
				}
				else
				{
					container.appendChild(nodeArray[i]);
				}
			}

			for(var i =0, j = scriptArray.length; i < j; i++)
			{
				thisObj.addScript(scriptArray[i].text || scriptArray[i].textContent || scriptArray[i].innerHTML || "");
			}
		});
	};

	this.pageResize = function()
	{
		this.externResizefunc();
	};

	this.setPageResize = function(func)
	{
		this.externResizefunc = func;
	};

	this.setexternJSP = function(func)
	{
		this.externJSP = func;
	};

	this.setExternLoading = function(func){
		this.externLoading = func;
	};

	this.setExternPageHandle = function(func){
		this.externPageHandle = func;
	};

	this.append = function (container, data, clearTimer)
	{
		if (container&&(container.nodeType == 1)&&(typeof data === "string"))
		{
			this.addDomNode(container, data, clearTimer);
			this.pageResize();
		}
	};

	this.detectWidthImg = function(callBack)
	{
		var img = new Image();

		img.onload = function(){
			callBack();
		};

		img.src = this.domainUrl + "/luci-static/images/favicon.ico?requence=" + Math.random();
	}

	this.detect = function (detectHandler)
	{
		if (true == isIETenLess)
		{
			this.detectWidthImg(detectHandler);
		}
		else
		{
			this.request((this.domainUrl+"/luci-static/images/nothing.png?_=20170809165512"), undefined, "get", this.asyn, detectHandler);
		}
	};

	this.loadHand = function(result, id, clearTimer){
		/* replace JSP str */
		str = this.externJSP(result.data);
		if (str != undefined)
		{
			result.data = str;
		}

		/* when session is out of date, jump to login page.*/
		if (this.unAuthCode == result.errorno)
		{
			return;
		}
		this.append(this.id(id), result.data, clearTimer);

		/* 此处进行页面集中的扩展处理 */
		try
		{
			this.externPageHandle(id);
		}catch(ex){};
	};

	/* 加载页面 */
	this.load = function (url, callback, id, clearTimer)
	{
		var timeout = false;
		var thisObj = this;

		function handler(result)
		{
			timeout = result.timeout;
			if (!timeout)
			{
				thisObj.loadHand(result, id, (clearTimer !== false));
			}

			if (callback)
			{
				callback(result);
			}
		}

		function unAuthHd(errNo){
			switch(errNo){
			case E_SYSRESET:
				$.setSession("");
				stateman.go("guide");
				break;
			case E_SESSIONTIMEOUT:
				$.setSession("");
				showAlert(label.loginTimeout, function(choose){
					stateman.go("login");
				});
				break;
			case E_UNAUTH:
				$.setSession("");
				stateman.go("login");
				break;
			default:
				showAlert(errStr.unknownErr + errNo);
				break;
			}
		}

		if (this.local || callback != undefined)
		{
			this.loadAsyn(url, this.ajaxTimeout, function(result){
				var errNo = E_NONE;
				try{
					errNo = result.errorno;
				}catch(ex){}

				if (errNo != E_NONE){
					unAuthHd(errNo);
				}else{
					handler(result);
				}
			});
		}
		else
		{
			this.request(this.orgURL(url), undefined, "get", this.syn);
			var errNo = E_NONE;
			try{
				errNo = result.errorno;
			}catch(ex){}

			if (errNo != E_NONE){
				unAuthHd(errNo);
			}else{
				handler(this.result);
			}
		}

		return timeout;
	};

	this.loadAsyn = function(url, timeoutPage, callback)
	{
		this.request(this.orgURL(url), undefined, "get", this.asyn, callback, timeoutPage);
	};

	this.sendAjax = function (url, data, callback, type)
	{
		var para;

		data = data || {}
		data._deviceType = OS.deviceType;

		para = JSON.stringify(
			data,
			function(key, value) {
				if (typeof(value) === "string") {
					return encodeURIComponent(value);
				}
				return value;
			}
		);

		url = this.orgURL(url);

		jQuery.ajax({
			'url': url,
			'data':	para,
			'type': type || "post",
			'contentType': 'application/json',
			'success': function(result){
				var code = result[ERR_CODE];
				switch(code){
				case E_SYSRESET:
					$.setSession("");
					stateman.go("guide");
					break;
				case E_SESSIONTIMEOUT:
					$.setSession("");
					showAlert(label.loginTimeout, function(choose){
						stateman.go("login");
					});
					break;
				case E_UNAUTH:
					$.setSession("");
					stateman.go("login");
					break;
				default:
					if ("function" === typeof callback){
						callback(result);
					}
				}
			},
			'error': function(xhr, status, err){
				console.error("sendAjax error:" + url + ", data:" + JSON.stringify(data));
				console.error(err);
			}
		});
	};
}

jQuery.ajaxSetup({
	converters: {
		"text json": function(data){
			return JSON.parse(data, function(k, v){
				var val = v;
				if (typeof val === "string"){
					try{
						val = decodeURIComponent(val);
					}catch(ex){}
				}

				return val;
				}
			);
		}
	}
});