function NiceScroll(targetId)
{
	this.taId = targetId;
	this.ta = id(this.taId);
	if (this.ta.nodeType != 1)
	{
		return null;
	}
	this.st = el("label");		// scroll tip
	this.sb = el("div");		// scroll bar
	this.sbH = 0;
	this.scH = 0;
	this.stH = 0;
	this.avg = 0;
	this.sbcH = 0;
	this.n = 20;
	this.enabled = true;
	this.mousePos = null;
	this.isScroll = false;
	this.onSb = false;
	this.show = false;
	this.checkTt = null;

	/* 滚动条动画效果相关 */
	this.wtId = null;			//动画timer的ids
	this.wtCounter = 0;			//timer循环次数
	this.wSpeed = 0;			//timer执行一次滚动条移动的距离
	this.woSpeed = 0;			//用于检测是否反向滚动
	/* endof 滚动条动画效果相关 */

	/* scrollBar的相关样式 */
	this.sbStyle = {
		"position":"fixed",
		"zIndex":1005,
		"width":"0.45em"
	};

	/* scrollTip的相关样式 */
	this.stStyle = {
		"width":"0.45em",
		"display":"inline-block",
		"backgroundColor":"#E7E7E7",
		"borderRadius":"3px",
		"position":"relative",
		"cursor":"pointer"
	};

	/* scrollTip的opacity */
	this.stOpacity = 0.1;

	if (typeof this.init != "function")
	{
		NiceScroll.prototype.init = function(){
			var obj = this;
			this.sb.id = this.taId + "niceScrollSb" + new Date().getTime();

			setStyle(this.sb, {"backgroundColor":(this.sbStyle.background || "transparent")});

			/* 将scrollTip添加到scrollBar中 */
			this.sb.appendChild(this.st);

			/* 将scrollBar添加到body中 */
			document.body.appendChild(this.sb);

			/* 设置scrollBar和scrollTip的静态样式 */
			setStyle(this.sb, this.sbStyle);
			setStyle(this.st, this.stStyle);

			/* 设置scrollBar和scrollTip的动态样式 */
			this._reset();

			/* 如果是PC浏览器设置target的overflow为hidden */
			if (false == OS.portable)
			{
				setStyle(this.ta, {"overflow":"hidden"});
			}
			else
			{
				setStyle(this.ta, {"overflow":"scroll"});
			}

			this._shSb();
			this._bind();
			window.setTimeout(function(){
				obj.checkTt = window.setTimeout(arguments.callee, 10);
				obj._check();
			}, 100);
		};

		/* 设置scrollBar的样式 */
		NiceScroll.prototype.scrollBarSet = function(styles){
			if (typeof styles == "object")
			{
				for(var propy in styles)
				{
					this.sbStyle[propy] = styles[propy];
				}
			}
		};

		/* 设置scrollTip的样式 */
		NiceScroll.prototype.scrollTipSet = function(styles){
			if (typeof styles == "object")
			{
				for(var propy in styles)
				{
					this.stStyle[propy] = styles[propy];
				}
			}
		};

		/* 设置scrollTip的opacity */
		NiceScroll.prototype.scrollTipOpacity = function(opacity){
			this.stOpacity = opacity;
		};

		/* 滚动到指定的位置 */
		NiceScroll.prototype.scrollTo = function(hPos){
			var scollTop = parseInt(hPos);

			if (true == isNaN(scollTop))
			{
				return false;
			}

			/* 设置scrollTip初始样式 */
			this.ta.scrollTop = scollTop;
		};

		/* 动态设置scrollBar和scrollTip的样式，主要是位置 */
		NiceScroll.prototype._reset = function(){
			var pos = $(this.ta).offset();
			var width = this.ta.offsetWidth;
			var height = this.ta.offsetHeight;
			var sHeight = this.ta.scrollHeight;
			var bdTWidth = parseFloat(getNodeDefaultView(this.ta, "borderTopWidth")) || 0;
			var bdBWidth = parseFloat(getNodeDefaultView(this.ta, "borderBottomWidth")) || 0;
			var bdRWidth = parseFloat(getNodeDefaultView(this.ta, "borderRightWidth")) || 0;
			var bdLWidth = parseFloat(getNodeDefaultView(this.ta, "borderLeftWidth")) || 0;

			this.scH = sHeight - height + bdTWidth + bdBWidth;
			this.stH = parseInt(height/sHeight*height*0.7);
			this.sbcH = height - (this.stH + 2);
			this.avg = this.scH/this.sbcH;

			if (sHeight - height <= 0)
			{
				setStyle(this.sb, {"visibility":"hidden", "top":"-9999px"});
				this.show = false;
				return;
			}
			else
			{
				this.show = true;
				setStyle(this.sb, {"visibility":"visible"});
			}

			/* 设置scrollBar初始样式 */
			setStyle(this.sb, {"top":pos.top + bdTWidth + "px",
							   "height":height + "px",
							   "left":pos.left + width - bdRWidth - parseInt(this.sb.offsetWidth) + "px"});

			/* 设置scrollTip初始样式 */
			setStyle(this.st, {"top":(this.ta.scrollTop/this.scH)*this.sbcH + "px",
							   "height":this.stH + "px"});

			/* fadeTo在此处会导致内存泄漏 */
			/*if (this.isScroll == false)
			{
				$("#"+this.sb.id).fadeTo(1000, this.stOpacity);
			}*/
		};

		NiceScroll.prototype._bind = function(){
			var obj = this;
			if (document.attachEvent)
			{
				this.ta.attachEvent("onmousewheel",  function(event){
					event = event || window.event;obj._scroll(event);event.cancelBubble = true;});
				this.sb.attachEvent("onmousewheel",  function(event){
					event = event || window.event;obj._scroll(event);event.cancelBubble = true;});
			}
			else
			{
				this.ta.addEventListener("mousewheel",
					function(event){event = event || window.event;obj._scroll(event);event.stopPropagation();}, false);
				this.ta.addEventListener("DOMMouseScroll",
					function(event){event = event || window.event;obj._scroll(event);event.stopPropagation();}, false);
				this.sb.addEventListener("mousewheel",
					function(event){event = event || window.event;obj._scroll(event);event.stopPropagation();}, false);
				this.sb.addEventListener("DOMMouseScroll",
					function(event){event = event || window.event;obj._scroll(event);event.stopPropagation();}, false);
			}

			/* 触屏移动的处理函数 */
			function touchMoveHd(event)
			{
				event = event || window.event;
				var mousePos = {x:event.touches[0].clientX, y:event.touches[0].clientY};
				var len = mousePos.y - obj.mousePos.y;
				var top = parseFloat(obj.st.style.top) - len;

				top = (top >= obj.sbcH?obj.sbcH:(top <= 0?0:top));
				obj.st.style.top = top + "px";
				obj.mousePos.y = mousePos.y;
				obj.isScroll = true;

				if (false == OS.portable)
				{
					obj.ta.scrollTop = obj.scH*(top/obj.sbcH);
					eventPreventDefault(event);
				}

				clearSelection(event);
			}

			/* 触屏结束移动的处理函数 */
			function touchEndHd(event)
			{
				detachEvnt(document, "touchmove", touchMoveHd);
				detachEvnt(document, "touchend", touchEndHd);

				if (obj.onSb == false)
				{
					obj.isScroll = false;
				}
			}

			/* 触屏移动开始的处理函数 */
			attachEvnt(this.ta, "touchstart", function(event){
				event = event || window.event;
				obj.mousePos = {x:event.touches[0].clientX, y:event.touches[0].clientY};
				attachEvnt(document, "touchmove", touchMoveHd);
				attachEvnt(document, "touchend", touchEndHd);
			});

			/* 对滑动块绑定鼠标函数 */
			this.st.onmousedown = function(event){
				obj.mousePos = getMousePos(event);
				document.onmouseup = function(event){
					document.onmousemove = null;
					document.onmouseup = null;
					if (obj.onSb == false)
					{
						obj.isScroll = false;
					}
				};
				document.onmousemove = function(event){
					var mousePos = getMousePos(event);
					var len = mousePos.y - obj.mousePos.y;
					var top = parseFloat(obj.st.style.top) + len;
					
					top = (top >= obj.sbcH?obj.sbcH:(top <= 0?0:top));
					obj.st.style.top = top + "px";
					obj.mousePos.y = mousePos.y;
					obj.ta.scrollTop = obj.scH*(top/obj.sbcH);
					obj.isScroll = true;
					clearSelection(event);
				};
			};

			/* 在scrollBar上绑定鼠标事件 */
			$("#"+this.sb.id)[0].onmouseover = function(event){
				event = event || window.event;
				obj.onSb = true;
				if (obj.show == true)
				{
					obj._scrollShow(event);
				}
			};
			$("#"+this.sb.id)[0].onmouseout = function(){
				obj.onSb = false;
				obj.isScroll = false;
			};
		};

		NiceScroll.prototype._close = function(){
			this.sb.style.visibility = "hidden";
			this.enabled = false;
		};

		NiceScroll.prototype._open = function(){
			this.enabled = true;
		};

		NiceScroll.prototype._shSb = function(){
			if (this.ta.style.display == "none" ||
				this.ta.visibility == "hidden")
			{
				this.sb.style.visibility = "hidden";
			}
			else
			{
				this.sb.style.visibility = "visible";
			}
		};

		NiceScroll.prototype._check = function(){
			if (id(this.taId) == null)
			{
				window.clearTimeout(this.checkTt);
				this.sb.parentNode.removeChild(this.sb);
				return;
			}
			if (this.enabled == false)
			{
				return;
			}

			if (checkInHorize(this.ta) == false)
			{
				this.sb.style.display = "none";
				return;
			}
			else
			{
				this.sb.style.display = "block";
			}
			
			if (parseInt(this.ta.offsetHeight) <= 0)
			{
				this.sb.style.visibility = "hidden";
			}
			this._reset();
		};

		NiceScroll.prototype._getWheelDelta = function(event){
			event = event || window.event;
			if (event.wheelDelta)
			{
				return window.opera&&window.opera.version < 9.5?-event.wheelDelta:event.wheelDelta;
			}
			else
			{
				return -event.detail*40;
			}
		};

		NiceScroll.prototype._wheelAnimate = function(speed, counter){
			var obj = this, oppsite = false;
			if (this.wtId)	/* 连续触发 */
			{
				oppsite = (this.woSpeed ^ speed) < 0;
				this.wtCounter = oppsite ? counter : (this.wtCounter + counter < 50 ? this.wtCounter + counter : 50);
				this.wSpeed = oppsite? speed : this.wSpeed*1.05;		/* 加速 */
				return;
			}
			this.wtCounter = counter;
			this.woSpeed = this.wSpeed = speed;
			(function()
			{
				var temp = 0;
				
				obj.wtId = window.setTimeout(arguments.callee, 5);
				if (obj.wtCounter < 0)
				{
					clearTimeout(obj.wtId);
					obj.wtId = null;
					if (obj.onSb == false)
					{
						obj.isScroll = false;
					}
					return;
				}
				var newTop = parseFloat(obj.ta.scrollTop) + parseInt(obj.wSpeed);
				if (newTop >= obj.scH || newTop <= 0)
				{
					obj.wtCounter = 0;
				}
				obj.ta.scrollTop = newTop;
				temp = (obj.ta.scrollTop/obj.scH)*obj.sbcH;
				if (!isNaN(temp))
				{
					obj.st.style.top = temp + "px";	/* 同步滚动条 */
				}
				obj.wtCounter--;
			})();
		};

		NiceScroll.prototype._scrollShow = function(event){
			$("#"+this.sb.id).stop(true).css("visibility", "visible").css("opacity", 1);
			this.isScroll = true;
			eventPreventDefault(event);
		};

		NiceScroll.prototype._scroll = function(event){
			event = event || window.event;
			var delta = this._getWheelDelta(event);
			var st = this.ta.scrollTop;
			var result = delta > 0?-1:1;
			if (this.show == true && this.enabled == true)
			{
				this._scrollShow(event);
				this._wheelAnimate(5 * result, 7);
			}
		};
	}
}

function Select()
{
	this.initSelect = function(idStr, options, value, callback, maxSize)
	{
		var li, tmp, parent, valueCon, visible = "hidden";
		var ul = document.createElement("ul");
		var con = id(idStr), className = "sel-opts-ul";
		var colorN = "#FFFFFF", colorC = "#F0F0F0";
		var fontColorN = "", fontColorC = "#4F5356";
		var valueColor = "#000000", valueDisColor = "#DCDCDC";
		var valueConTmp, showSize, valueConWidth, fontSize;
		var escapeStr, listScroll, valueDef = value;

		parent = con.parentNode;
		valueConTmp = $("#"+idStr+" span.value");
		fontColorN = valueConTmp.css("color");
		valueCon = valueConTmp[0];
		valueCon.value = 0;
		valueConWidth = parseInt(valueConTmp.css("width"));
		fontSize = (parseInt(valueConTmp.css("fontSize"))*0.61).toFixed(1);
		showSize = (maxSize == undefined ? parseInt(valueConWidth/fontSize) : maxSize);
		con.value = 0;
		ul.className = className;
		ul.id = className + idStr;
		parent.appendChild(ul);

		function hiddenSelect(ul)
		{
			var visibilityVal, li;
			var options = ul.childNodes;

			for (var i = 0, len = options.length; i < len; i++)
			{
				li = options[i];
				visibilityVal = li.childNodes[0].style.visibility;
				li.style.backgroundColor = (visibilityVal == "visible"?colorC:colorN);
				li.style.color = (visibilityVal == "visible"?fontColorC:fontColorN);
			}

			ul.style.visibility = "hidden";
			ul.style.top = "-9999px";
			ul.parentNode.style.position = "static";
		}

		attachEvnt(document.body, "click", function(){
			var ul = $("#"+className + idStr)[0];

			if (typeof ul == "undefined")
			{
				return;
			}

			hiddenSelect(ul);
		});

		function optionClick(li)
		{
			var con = id(idStr)
			var target = li;
			var parent = target.parentNode;
			var options = parent.childNodes;
			var valueCon = $("#"+idStr+" span.value")[0];

			if (target.childNodes[0].nodeType == 3)
			{
				return;
			}

			con.value = target.valueStr;
			$("#"+idStr).attr("data-value", target.valueStr);
			valueCon.value = target.valueStr;

			for (var i = 0, len = options.length; i < len; i++)
			{
				options[i].childNodes[0].style.visibility = "hidden";
				options[i].style.backgroundColor = colorN;
				options[i].style.color = fontColorN;
			}

			if (target.childNodes[0].style.visibility != "visible" && 
				typeof callback != "undefined")
			{
				callback(target.valueStr, false);
			}

			target.childNodes[0].style.visibility = "visible";
			target.style.backgroundColor = colorC;
			target.style.color = fontColorC;
			valueCon.innerHTML = htmlEscape(target.childNodes[1].nodeValue);
			parent.style.visibility = "hidden";
			parent.style.top = "-9999px";
			parent.parentNode.style.position = "static";
		}

		function optionInit(options)
		{
			for (var i = 0, len = options.length; i < len; i++)
			{
				tmp = options[i];
				escapeStr = htmlEscape(getStrInMax(tmp.name.toString(), showSize));
				visible = "hidden";

				li = document.createElement("li");

				if ((tmp.value == undefined && i == valueDef) || (valueDef == tmp.value))
				{
					visible = "visible";
					valueCon.innerHTML = escapeStr;
					valueCon.value = valueDef;
					con.value = valueDef;
					$("#"+idStr).attr("data-value", valueDef);
					li.style.backgroundColor = colorC;
					li.style.color = fontColorC;
				}

				if (i == len - 1){
					li.style.borderBottomWidth = "0";
				}

				li.innerHTML = "<span style='visibility:" + visible + "'>√</span>" + escapeStr;
				li.title = tmp.name;
				li.valueStr = (tmp.value != undefined ? tmp.value : i);
				li.className = "option";
				li.style.color = fontColorN;
				li.onclick = function(event)
				{
					event = event || window.event;
					optionClick(this);
					stopProp(event);
				};

				li.onmousemove = function(event){
					event = event || window.event;
					var target = event.srcElement || event.target;
					var options;

					if (target.tagName.toLowerCase() == "span")
					{
						return;
					}

					options = target.parentNode.childNodes;

					for (var i = 0, len = options.length; i < len; i++)
					{
						options[i].style.backgroundColor = colorN;
						options[i].style.color = fontColorN;
					}

					target.style.backgroundColor = colorC;
					target.style.color = fontColorC;
				};

				ul.appendChild(li);
			}
		}

		function selectClick(event)
		{
			var target = $("#"+ className + idStr);
			var sel = $("ul."+ className);

			/* 先隐藏其他下拉列表 */
			sel.each(function(){
				if (this.style.visibility == "visible")
				{
					hiddenSelect(this);
				}
				return true;
			});

			target.css("visibility", "visible").css("top", "-1px");
			target[0].parentNode.style.position = "relative";
			stopProp(event);
		}

		optionInit(options);

		con.onclick = selectClick;
		con.disable = function(value){
			con.onclick = (value == true ? null : selectClick);
			valueCon.style.color = (value == true ? valueDisColor : valueColor);
		};
		con.changeSel = function(value){
			var selOptions = $("#"+ className + idStr+" li");

			$("#"+ className + idStr+" li").each(function(){
				if (this.valueStr == value)
				{
					optionClick(this);
					return false;
				}
			});
		};
		con.resetOptions = function(options, value){
			ul.innerHTML = "";
			valueDef = value || 0;
			optionInit(options);
		};

		callback && callback(valueDef, true);

		listScroll = new NiceScroll(ul.id);
		listScroll.scrollBarSet({width:"0.35em"});
		listScroll.scrollTipSet({width:"0.35em"});
		listScroll.init();
	};
}

function DateControl(dateConId, options)
{
	this.table;
	this.weekList;
	this.hourList;
	this.dateCon = id(dateConId);
	this.weekIsMouseDown = false;
	this.selDate = [0, 0, 0, 0, 0, 0, 0];
	this.dateArray = [0, 0, 0, 0, 0, 0, 0];
	this.cellHeight = 18;
	this.cellWidth = 62;
	this.cellSeColor = "#FF9002";
	this.cellDeColor = "#FAFAFA";
	this.cellPadding = 1;

	if (DateControl.prototype.init == undefined)
	{
		DateControl.prototype.weekDayNum = 7;
		DateControl.prototype.lineStr = "-";
		DateControl.prototype.selTag = "selTag";
		DateControl.prototype.cellBorderWidth = 1;
		DateControl.prototype.iCellIndex = 0;
		DateControl.prototype.weekArray = [label.Monday, label.Tuesday, label.Wednesday, 
										   label.Thursday, label.Friday, label.Saturday, label.Sunday];

		/* Date的初始化 */
		DateControl.prototype._init = function()
		{
			this._initOptions();
			this._dateConInit();
            this._weekListInit();
			this._hourListInit();
			this._dateTableInit();
		};

		/* 重新设置显示的时间 */
		DateControl.prototype.reset = function(dateArray)
		{
			var dayMask, tr, td, iCell, iCellIndex = this.iCellIndex;
			var objThis = this;

			if (dateArray instanceof Array == false ||
				dateArray == undefined || 
				dateArray.length != this.weekDayNum)
			{
				return;
			}

			for(var j = 0; j < this.weekDayNum; j++)
			{
				tr = this.table.rows[j];
				dayMask = dateArray[j];

				for (var i = 0; i < 24; i++)
				{
					td = tr.cells[i];
					iCell = td.childNodes[iCellIndex];

					if (dayMask != undefined)
					{
						this._setSel(iCell, dayMask%2);
						dayMask = (dayMask >> 1);
					}
					else
					{
						this._setSel(iCell, 0);
					}
				}
			}
		};

		/* 初始化options */
		DateControl.prototype._initOptions = function()
		{
			for (var propty in options)
			{
				if (typeof this[propty] != "undefined")
				{
					this[propty] = options[propty];
				}
			}
		};

		/* 获取已选择的时间 */
		DateControl.prototype.getSelDate = function()
		{
			var cell, selectNum, row, iCell;
			var weekDayNum = this.weekDayNum;
			var rows = this.table.rows;
			this.selDate = [0, 0, 0, 0, 0, 0, 0];

			for(var j = 0; j < 24; j++)
			{
				row = rows[j];

				for (var i = 0; i < weekDayNum; i++)
				{
					cell = row.cells[i];
					iCell = cell.childNodes[0];
					selectNum = parseInt(iCell.getAttribute("sel"));

					if (selectNum == 1)
					{
						this.selDate[i] |= Math.pow(2, j);
					}
				}
			}

			return this.selDate;
		};

		DateControl.prototype._dateConInit = function()
		{
			this.dateCon.style.overflow = "hidden";
		};

		/* 时刻列表初始化 */
		DateControl.prototype._hourListInit = function()
		{
			var hourList = document.createElement("ul");
			var li, text, iCell, thisObj = this, span;

			hourList.className = "hourList";

			for(var i = 0; i <= 24; i++)
			{
				li = document.createElement("li");
				iCell = document.createElement("span");
                iCell.innerHTML = (i >= 10) ? (i + ":00") : ("0" + i + ":00");
                li.appendChild(iCell);
                li.style.width = this.cellWidth + this.cellPadding*2 + this.cellBorderWidth + "px";
                iCell.onclick = (function(index){
                    return function(){
                        var rows = thisObj.table.rows;
                        var len = rows.length;
                        var iCellIndex = thisObj.iCellIndex;
                        var selMask = 1;

                        for (var j = 0; j < len; j++)
                        {
                            selMask = selMask&parseInt(rows[j].cells[index].childNodes[iCellIndex].getAttribute("sel"));
                            if (0 == selMask)
                            {
                                break;
                            }
                        }

                        selMask = 1 - selMask;

                        for (var j = 0; j < len; j++)
                        {
                            thisObj._setSel(rows[j].cells[index].childNodes[iCellIndex], selMask);
                        }

                        clearSelection();
                    };
                })(i);

				hourList.appendChild(li);
			}

			this.dateCon.appendChild(hourList);
			this.hourList = hourList;
		};

		/* 星期列表初始化 */
		DateControl.prototype._weekListInit = function()
		{
			var weekList = document.createElement("ul");
			var li, thisObj = this;

			weekList.className = "weekList";

			for(var i = 0, len = this.weekDayNum; i < len; i++)
			{
				li = document.createElement("li");
				li.style.height = this.cellHeight + this.cellPadding*2 + this.cellBorderWidth + "px";
				li.style.lineHeight = this.cellHeight + this.cellPadding*2 + this.cellBorderWidth + "px";
				li.innerHTML = this.weekArray[i];
				li.onclick = (function(index){
					return function(){
						var cells = thisObj.table.rows[index].cells;
						var iCellIndex = thisObj.iCellIndex;
						var selMask = 1;

						for (var j = 0, len = cells.length; j < len; j++)
						{
							selMask = selMask&parseInt(cells[j].childNodes[iCellIndex].getAttribute("sel"));
							if (0 == selMask)
							{
								break;
							}
						}

						selMask = 1 - selMask;

						for (var j = 0, len = cells.length; j < len; j++)
						{
							thisObj._setSel(cells[j].childNodes[iCellIndex], selMask);
						}

						clearSelection();
					};
				})(i);
				weekList.appendChild(li);
			}

			this.dateCon.appendChild(weekList);
			this.weekList = weekList;
		};

		/* 设置时间块是否被选择 */
		DateControl.prototype._setSel = function(obj, num){
			obj.setAttribute("sel", num);
			obj.style.backgroundColor = (num == 1 ? this.cellSeColor : this.cellDeColor);
		};

		/* 生成时间cell */
		DateControl.prototype._dateCellCreate = function()
		{
			var dayMask, tr, td, iCell, index;
			var objThis = this;

            for (var j = 0, len = 24; j < len; j++)
			{
				tr = this.table.insertRow(-1);

				for (var i = 0; i < this.weekDayNum; i++)
				{
					td = tr.insertCell(-1);
					td.style.padding = this.cellPadding + "px";
					td.className = "weekTd";

					iCell = document.createElement("i");
					iCell.className = "tableICell";
					iCell.style.height = this.cellHeight + "px";
					iCell.style.width = this.cellWidth + "px";
					td.appendChild(iCell);

                    dayMask = this.dateArray[i] >> j;
                    this._setSel(iCell, dayMask%2);

					iCell.onmouseover = function (event){
						if (objThis.weekIsMouseDown == true)
						{
							objThis._setSel(this, 1 - parseInt(this.getAttribute("sel")));
						}
					};

					iCell.onmousedown = function (event){
						objThis._setSel(this, 1 - parseInt(this.getAttribute("sel")));
					};
				}
			}

			if (this.table.rows[0].cells[0].nodeType == 3)
			{
				this.iCellIndex = 1;
			}
		};

		/* 添加处理函数 */
		DateControl.prototype._dateCellBind = function()
		{
			var objThis = this;
			this.table.onmousedown = function (event){
				objThis.weekIsMouseDown = true;
				document.onmouseup = function (event){
					objThis.weekIsMouseDown = false;
				}
			};

			this.table.onmouseup = function (event){
				objThis.weekIsMouseDown = false;
			};
		};

		/* 生成时间表 */
		DateControl.prototype._dateTableCreate = function()
		{
			this.table = document.createElement("table");
			this.table.className = "tableWeek";
			this.table.cellspacing = "0px";
			this.table.cellpadding = "0px";
			this.dateCon.appendChild(this.table);
		};

		/* 初始化具体的时间表格 */
		DateControl.prototype._dateTableInit = function()
		{
			this._dateTableCreate();
			this._dateCellCreate();
			this._dateCellBind();
		};
	}

	this._init();
}

(function(){
	Select.call(window);
})();
