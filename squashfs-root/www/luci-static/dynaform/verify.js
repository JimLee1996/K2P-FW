/* 合法性校验库 */
function Checks()
{
	/* 检查IP地址类型是否合法（E类IP地址认定为非法） */
	this.validIpAddr = function(value, checkOption)
	{
		var ipByte = value.split(".");
		var result = true;

		for(var i = 1, len = ipByte.length; i < len; i++)
		{
			if (255 < ipByte[i])
			{
				return E_INVIP;
			}
		}

		/* 网段非法 */
		if (false == result || (0 == ipByte[0]) || 0xE0 < ipByte[0])
		{
			return E_INVNET;
		}

		/* 组播IP地址 */
		if ((undefined == checkOption || true != checkOption.unCheckMutiIp) && 0xE0 == ipByte[0])
		{
			return E_INVGROUPIP;
		}

		/* 回环IP地址 */
		if ((undefined == checkOption || true != checkOption.unCheckLoopIp) && 127 == ipByte[0])
		{
			return E_INVLOOPIP;
		}

		return E_NONE;
	};

	/* 检查IP地址格式是否正确 */
	this.validIpFormat = function (value)
	{
		var result = /^([0-9]{1,3}\.){3}([0-9]{1,3})+$/g.test(value);
		return (result == true ? E_NONE : E_INVIPFMT);
	};

	/* 检查IP是否合法 */
	this.checkIp = function(value, checkOption)
	{
		var result = E_NONE;

		if (0 == value.length)
		{
			return E_INVIP;
		}

		if (E_NONE != (result = this.validIpFormat(value)))
		{
			return result;
		}

		if (E_NONE != (result = this.validIpAddr(value, checkOption)))
		{
			return result;
		}

		return result;
	};

	/* 检查MAC地址范围是否合法 */
	this.validMacAddr = function(value)
	{
		var charSet = "0123456789abcdef";
		var macAddr = value.toLowerCase();

		if (macAddr == "00:00:00:00:00:00")
		{
			return E_INVMACZERO;
		}

		if (macAddr == "ff:ff:ff:ff:ff:ff")
		{
			return E_INVMACBROAD;
		}

		if (1 == charSet.indexOf(macAddr.charAt(1)) % 2)
		{
			return E_INVMACGROUP;
		}

		return E_NONE;
	};

	/* 检查MAC地址格式是否合法 */
	this.validMacFormat = function(value)
	{
		var result = /^([0-9a-f]{2}:){5}([0-9a-f]{2})+$/gi.test(value);

		return (result == true ? E_NONE : E_INVMACFMT);
	};

	/* 检查MAC地址是否正确 */
	this.checkMac = function(value)
	{
		var result = E_NONE;

		if (0 == value.length)
		{
			return E_MACEMPTY;
		}

		if (E_NONE != (result = this.validMacFormat(value)))
		{
			return result;
		}

		if (E_NONE != (result = this.validMacAddr(value)))
		{
			return result;
		}

		return result;
	};

	/* 检查子网掩码是否正确 */
	this.checkMask = function(value)
	{
		var maskVal, maskTmp = 0x00000001;

		if (E_NONE != this.validIpFormat(value))
		{
			return E_INVMASK;
		}

		maskVal = this.transIp(value)

		if (0xFFFFFFFF == maskVal){
			return E_INVMASK;
		}

		for (var index = 0; index < 32; index++, maskTmp <<= 1)
		{
			if (0x00 != (maskTmp & maskVal))
			{
				if (0 == (maskVal ^ (0xFFFFFFFF << index)))
				{
					return E_NONE;
				}

				return E_INVMASK;
			}
		}

		return E_INVMASK;
	};

	/* 检查MTU值是否在规定范围内 */
	this.checkMtu = function(value, max, min)
	{
		var result = E_NONE;

		if (this.checkNum(value) == false)
		{
			return E_INVMTUSTATIC;
		}

		if (max == undefined)
		{
			max = 1500;
			min = 576;
		}

		if (false == this.checkNumRange(parseInt(value), max, min))
		{
			return E_INVMTUSTATIC;
		}

		return E_NONE;
	};

	/* 使用掩码检查IP是否合法 */
	this.checkIpMask = function(ipValue, maskValue)
	{
		var maskVal = this.transIp(maskValue);
		var ipVal = this.transIp(ipValue);
		var result = this.checkIPNetHost(ipVal, maskVal);

		if (result != E_NONE)
		{
			return result;
		}

		result = this.checkIpClass(ipValue, maskValue);

		/* 子网掩码比IP地址网络号小 */
		if (result != E_NONE)
		{
			return result;
		}

		return E_NONE;
	};

	/* 将点分格式的IP转换为整数 */
	this.transIp = function(val)
	{
		var value = val.split(".");
		return (0x1000000 * value[0] + 0x10000 * value[1] + 0x100 * value[2] + 1 * value[3]);
	};

	/* 获取汉字的长度 */
	this.getCNStrLen = function(str)
	{
		return str.replace(/[^\x00-\xFF]/g, "xxx").length;
	};

	/* 获取IP类型：A、B、C、D、E */
	this.getIpClass = function(value)
	{
		var ipByte = value.split(".");
		if (ipByte[0] <= 127)
		{
			return 'A';
		}
		if (ipByte[0] <= 191)
		{
			return 'B';
		}
		if (ipByte[0] <= 223)
		{
			return 'C';
		}
		if (ipByte[0] <= 239)
		{
			return 'D';
		}
		return 'E';
	};

	/* 检查是否含有非数字的字符 */
	this.checkNum = function(value)
	{
		/* 返回值为true表明是纯数字，false表明不是纯数字 */
		if ("" == value)
		{
			return false;
		}
		else
		{
			return (!(/\D/g.test(value)));
		}
	};

	/* 检测主机号和网络号是否全是0/1 */
	this.checkIPNetHost = function(ipVal, maskVal)
	{
		/* 网络号全0/1 */
		if (0x0 == (ipVal & maskVal) || maskVal == (ipVal & maskVal))
		{
			return E_INVNETID;
		}

		/* 主机号全0/1(源地址/广播地址) */
		if (0x0 == (ipVal & (~maskVal)) || (~maskVal) == (ipVal & (~maskVal)))
		{
			return E_INVHOSTID;
		}

		return E_NONE;
	};

	/* 检查Ip类型是否合法 */
	this.checkIpClass = function(ipValue, maskValue)
	{
		var netId = this.getIpClass(ipValue);
		var ipVal = this.transIp(ipValue);
		var maskVal = this.transIp(maskValue);

		switch(netId)
		{
		case 'A':
			ipVal &= 0xFF000000;
			break;
		case 'B':
			ipVal &= 0xFFFF0000;
			break;
		case 'C':
			ipVal &= 0xFFFFFF00;
			break;
		}

		return (maskVal > ipVal ? E_NONE : E_INVIPMASKPAIR);
	};

	/* 检查输入的值是否在规定的范围内 */
	this.checkStrLen = function(value, maxLen, minLen)
	{
		var len = this.getCNStrLen(value);

		if (minLen > len || maxLen < len)
		{
			return E_STRINGLEN;
		}

		return E_NONE;
	};

	/* 检查给出的值是否在指定的范围内 */
	this.checkNumRange = function(value, max, min)
	{
		if (isNaN(value) || value < min || value > max)
		{
			return false;
		}

		return true;
	};

	/* 检查SSID是否合法：1-32个字符 */
	this.checkSsid = function(ssid)
	{
		var len = getCNStrLen(ssid);

		if ("" == ssid){
			return E_SSID_BLANK;
		}

		if (len < 1 || len > 32){
			return E_SSID_LEN;
		}

		return E_NONE;
	};

	/* 检查无线密码是否合法：8-63个字符 */
	this.checkWlanPwd = function(wlanPwd)
	{
		var pwdLen = getCNStrLen(wlanPwd);

		if (false == checkIllegalChar(wlanPwd)){
			return E_WIFI_PWD_ILLEGAL;
		}

		if (pwdLen > 63 || pwdLen < 8){
			return E_WIFI_PWD_LEN;
		}

		return E_NONE;
	};

	/* 检查无线密码是否含有非法字符 */
	this.checkIllegalChar = function(value){
		var ch = "0123456789ABCDEFabcdefGHIJKLMNOPQRSTUVWXYZghijklmnopqrstuvwxyz`~!@#$^&*()-=_+[]{};:\'\"\\|/?.,<>/% ";
		var chr;

		for (var i = 0, len = value.length; i < len; i++){
			chr = value.charAt(i);
			if (ch.indexOf(chr) == -1){
				return false;
			}
		}

		return true;
	};

	/* 检查默认网关 */
	this.checkGateway = function(gateway)
	{
		return E_NONE != checkIp(gateway) ? E_INVGTW : E_NONE;
	};

	/* 检查首选DNS */
	this.checkPrimDns = function(priDns)
	{
		return E_NONE != checkIp(priDns) ? E_INVFDNSIP : E_NONE;
	};

	/* 检查备用DNS */
	this.checkSeDns	= function(secDns, secDnsId)
	{
		if ("" == secDns)
		{
			return E_NONE;
		}

		return E_NONE != checkIp(secDns) ? E_INVSDNSIP : E_NONE;
	};

	/* 检查 ip1 & ip2 是否在同一网段 */
	this.checkSameNetwork = function(ip1, ip2, mask)
	{
	    ip1 = "number" == typeof(ip1) ? ip1 : this.transIp(ip1);
	    ip2 = "number" == typeof(ip2) ? ip2 : this.transIp(ip2);
	    mask = "number" == typeof(mask) ? mask : this.transIp(mask);

	    return ((ip1 &= mask) == (ip2 &= mask));
	}

	/* 检查域名是否含有非法字符 */
	this.checkDomain = function(domain)
	{
		if (domain.length > 255){
			return false;
		}

		/* 检查域名是否含有非法字符 */
		var reg = /^[a-zA-Z0-9\.\-]+$/;
		if (!(reg.test(domain))){
			return false;
		}

		var tokens = domain.split(".");
		for(var i = 0; i < tokens.length; i++){
			if (tokens[i].length == 0 || tokens[i].length >= 64){
				return false;
			}
		}

		return true;
	}
}

(function(){
	Checks.call(window);
})();
