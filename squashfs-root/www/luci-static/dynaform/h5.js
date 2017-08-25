function Select()
{
	this.initSelect = function(selectObjId, lists, value, callback){
		function initSelect(lists, value, callback){
			var name, val;
			var len = lists.length;
			var selectList = "";
			for (var i = 0; i < len; i++){
				name = htmlEscape(lists[i].name);
				val = htmlEscape(lists[i].value);
				if (val == value){
					selectList += '<li class="sel-item selected" data-value="' + val + '"><span>' + name + '</span></li>';
				}else{
					selectList += '<li class="sel-item" data-value="' + val + '"><span>' + name + '</span></li>';
				}
			}

			var titleStr = $("#"+selectObjId).parent().prev(".desc-lbl").text();

			var popCon =
						'<div class="pop-con">' +
							'<p class="sel-title">' + titleStr +'</p>' +
							'<ul class="sel-list">' + selectList + '</ul>' +
						'</div>' +
						'<div class="sel-btn-con">' +
							'<input onclick="closeSelect()" class="sel-btn" type="button" value="' + btn.cancel+ '" />' +
						'</div>';

			$("#Cover").fadeIn("fast");
			$("#Pop").empty().append(popCon).addClass("bottom-widget").show();
			$("#Pop ul.sel-list").delegate("li","click",function(){
				closeSelect();

				var val = $(this).attr("data-value");
				var text = $(this).children("span").text();
				$("#"+selectObjId).attr("data-value", val).children("span.select-value").text(text);

				callback && callback(val, false);
			});
		}

		var val, spanStr, len;
		len = lists.length;

		if (value != undefined){
			val = value;
		}else{
			val = $(this).attr("data-value");
		}

		for (var i = 0; i < len; i++){
			if (lists[i].value == val){
				spanStr = lists[i].name;
				break;
			}
		}

		id(selectObjId).disable = function(value){
			if (value){
				$(this).attr('disabled', value).css("color", "#DCDCDC");
			}else{
				$(this).removeAttr("disabled").css("color", "#575757");
			}
		};

		$("#"+selectObjId).click(function(){
			if ($(this).attr('disabled')){
				return;
			}

			var val = $(this).attr("data-value");
			initSelect(lists, val, callback);
		}).attr("data-value", val).children(".select-value").text(spanStr);

		callback && callback(val, true);
	};

	this.closeSelect = function(){
		$("#Pop").hide().removeClass("bottom-widget");
		$("#Cover").fadeOut("fast");
	};
}

(function(){
	Select.call(window);
})();
