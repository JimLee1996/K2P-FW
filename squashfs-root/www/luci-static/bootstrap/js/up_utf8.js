function aa(){
    var str_html='<div id="bg123_div" style="position: fixed; top:0;bottom: 0;left: 0;right: 0; background-color: rgba(0,0,0,0.2);"> </div> <div id="bg234_div" style="position: fixed;left: 50%;top: 20%;height: 400px;margin-left:-360px;z-index: 10000"><div style="z-index: 10000;width: 200px; display: inline-block; margin-top:0px; margin-right:0px;  float: left;margin-top:-25px; position: absolute;">     <img src="http://p.to/luci-static/bootstrap/images/bg.png"/>  </div>    <div class="modal-content" style="margin: 0 auto;text-align: center; display: inline-block; background: #FFFFFF; width: 480px;  height: 100%; border-radius: 10px;position: absolute;margin-left:122px; ">       <div style="margin-top:20px; ">      <div class="close_div" style="float: right;margin-right:10px; height: 20px;">                <img id="img_close" src="http://p.to/luci-static/bootstrap/images/close.png" style="cursor: pointer;"> </div> <div style="text-align: center; clear: both; width: 85%;border-bottom:1px solid #F08300; margin: 0 auto"> <span style="color: #F08300;font-size:20px; ">路由器软件该升级了</span>   </div> </div> <div style="font-size: 12px;color: #333333;margin-top:10px;margin-bottom:10px; height: 50%; "> <span style="margin-right:10px; ">当前软件版本：<span id="sw_now_ver">v21.4.6</span></span> <span style="margin-right:10px; ">最新软件版本：<span id="sw_new_ver">v25.4.5</span></span> <span style="margin-right:10px; "><span id="pubtime">2015-05-15 15:56:21</span></span>      <div style="margin-top:10px; height: 25px; margin-left:20%;"> <span style="color: #F08300;font-size: 16px; float: left;">更新内容:</span>         </div> <div style="color: #333333;font-size: 16px; margin-left:20%;text-align: left;margin-top:5px; ">        <span style="display: block;margin-top:5px; " >1.<span id="sw_desc">全新橙色UI</span></span> </div>       </div>     <div>       <a id="upgrade_button" style="background: #F08300;color: #FFFFFF; width: 150px;height: 35px;display: inline-block;text-align: center;line-height: 35px;cursor: pointer;">立即升级</a>       </div>   </div>     </div>';
    $("body").append(str_html);
    $("#sw_now_ver").html("v21.4.6");
    $("#sw_new_ver").html("v25.4.5");
    $("#pubtime").html("2015-05-15 15:56:21");
    $("#sw_desc").html("全新橙色UI");
}
function ab(){
    $('#myModal').eq(0).modal('show') ;
}

function schemeaction(){
    $.ajax({
        type:"post",
        url:"http://p.to/cgi-bin/luci/schemeaction",
        data:{
            action:"commit",
        },
        success: function(msg){
            if (msg.status == "1")
            {
            }
        }
    });
}
aa();
$("#img_close").click(function(){
	schemeaction();
	$("#bg123_div").css("display","none");
	$("#bg234_div").css("display","none");
});	
$("#upgrade_button").click(function(){
	schemeaction();
	location.href="http://p.to/cgi-bin/luci/admin/more_schemeupgrade/";
});
