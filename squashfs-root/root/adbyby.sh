#!/bin/sh

#local mcmd=$1

adb_mod=`uci get adbyby.adbyby.mode 2>/dev/null`
https_en=`uci get adbyby.adbyby.https 2>/dev/null`
run_mode=`uci get adbyby.adbyby.runmode 2>/dev/null`

httpsip_flag=0
if [  -f "/etc/adbyby_httpsip.txt" ]  ;then
iflag=`cat /etc/adbyby_httpsip.txt|grep "\."`
if [ ! -z "$iflag" ] ;then
httpsip_flag=1
fi
fi

add_mac_rules() {
cat << EOF
 $mcmd
EOF
}


cd /tmp
#等待网络连接成功
wget_ok="0"
get_source="0"

while [ "$wget_ok" = "0" ] 
do 
if [ "$adb_mod" = "1" ]  ;then
 wget --no-check-certificate https://koolproxy.com/downloads/mipsel -O /tmp/mipsel -t 1 -T 5 2>/dev/null
 if [ "$?" == "0" ]; then
 wget_ok="1"
 else
  wget http://iytc.net/tools/mipsel_new -O /tmp/mipsel -t 1 -T 5 2>/dev/null
  if [ "$?" == "0" ]; then
  wget_ok="1"
  else
   sleep 30
  fi
 fi
else
wget http://update.adbyby.com/download/7620n.tar.gz -O /tmp/7620n.tar.gz -t 1 -T 5 2>/dev/null
if [ "$?" == "0" ]; then
wget_ok="1"
else
 wget http://www.yithinker.com/tools/7620n.tar.gz -O /tmp/7620n.tar.gz -t 1 -T 5 2>/dev/null
 if [ "$?" == "0" ]; then
 get_source="1"
 wget_ok="1"
 else
 sleep 30
 fi
fi
fi
done

#解压、启动adbyby
if [ "$adb_mod" = "1" ]  ;then
mkdir -p koolproxy
mv mipsel ./koolproxy/koolproxy
chmod 755 /tmp/koolproxy/koolproxy
else
mkdir -p adbyby 
tar -zxf 7620n.tar.gz -C ./adbyby  2>/dev/null
rm -f 7620n.tar.gz
fi

if [ -f "/tmp/boot_flag" ] ;then
sleep 30
fi

#更新一次规则
if [ "$adb_mod" = "1" ]  ;then
cd ./koolproxy
mkdir -p data/rules
wget  --no-check-certificate https://kprule.com/1.dat -O /tmp/koolproxy/data/rules/1.dat -t 1 -T 5 2>/dev/null
wget  --no-check-certificate https://kprule.com/koolproxy.txt -O /tmp/koolproxy/data/rules/koolproxy.txt -t 1 -T 5 2>/dev/null
if [ "$?" != "0" ]; then
wget http://iytc.net/tools/koolproxy_new.txt -O /tmp/koolproxy/data/rules/koolproxy.txt -t 1 -T 5 2>/dev/null
wget http://iytc.net/tools/1_new.dat -O /tmp/koolproxy/data/rules/1.dat -t 1 -T 5 2>/dev/null
fi

cp /etc/adbyby_user.txt  /tmp/koolproxy/data/rules/user.txt 2>/dev/null

if [ "$https_en" = "1" ]  ;then
 if [ ! -f "/etc/koolproxy/certs/ca.crt" ] ;then
  cd  /etc/koolproxy
 ./gen_ca.sh >/dev/null 2>&1   
  cp ./certs/ca.crt /www/kp.crt 2>/dev/null
 fi

cp -r /etc/koolproxy/certs  /tmp/koolproxy/data 2>/dev/null
cp -r /etc/koolproxy/private  /tmp/koolproxy/data 2>/dev/null
#wget http://iytc.net/tools/mozilla_cert.pem -O /tmp/koolproxy/data/certs/mozilla_cert.pem -t 1 -T 5 2>/dev/null
fi

#if [ -f "/tmp/koolproxy/data/rules/koolproxy.txt" -a -f "/tmp/koolproxy/data/rules/1.dat"  ] ;then
if [ -f "/tmp/koolproxy/koolproxy"  ] ;then
cd /tmp/koolproxy
./koolproxy -p 8118 >/dev/null 2>&1 &  
else
return 1
fi
else
murl=`cat /tmp/adbyby/bin/update.info|grep lazy.txt|awk '{print $1}'`

if [ ${#murl} -gt 5 ] ;then
murl2=`cat /tmp/adbyby/bin/update.info|grep lazy.txt|awk '{print $2}'`
mfile="/tmp/adbyby/bin"${murl2//\\//}
if [ "$get_source" == "0" ]; then
wget $murl -O $mfile -t 1 -T 5 2>/dev/null
else
wget http://www.yithinker.com/tools/lazy.txt -O $mfile -t 1 -T 5 2>/dev/null
fi
else
wget http://www.yithinker.com/tools/lazy.txt -O /tmp/adbyby/bin/data/lazy.txt -t 1 -T 5 2>/dev/null
fi

murl=`cat /tmp/adbyby/bin/update.info|grep video.txt|awk '{print $1}'`
if [ ${#murl} -gt 5 ] ;then
murl2=`cat /tmp/adbyby/bin/update.info|grep video.txt|awk '{print $2}'`
mfile="/tmp/adbyby/bin"${murl2//\\//}
if [ "$get_source" == "0" ]; then
wget $murl -O $mfile -t 1 -T 5 2>/dev/null
else
wget http://www.yithinker.com/tools/video.txt -O $mfile -t 1 -T 5 2>/dev/null
fi
else
wget http://www.yithinker.com/tools/video.txt -O /tmp/adbyby/bin/data/video.txt -t 1 -T 5 2>/dev/null
fi

murl=`cat /tmp/adbyby/bin/update.info|grep user.action|awk '{print $1}'`
if [ ${#murl} -gt 5 ] ;then
murl2=`cat /tmp/adbyby/bin/update.info|grep user.action|awk '{print $2}'`
mfile="/tmp/adbyby/bin"${murl2//\\//}
if [ "$get_source" == "0" ]; then
wget $murl -O $mfile -t 1 -T 5 2>/dev/null
else
wget http://www.yithinker.com/tools/user.action -O $mfile -t 1 -T 5 2>/dev/null
fi
else
wget http://www.yithinker.com/tools/user.action -O /tmp/adbyby/bin/user.action -t 1 -T 5 2>/dev/null
fi

cd ./adbyby/bin
sed -i '/hehe/d' adbybyfirst.sh 2>/dev/null
sed -i '/hehe/d' adbybyupdate.sh 2>/dev/null
if [ -f "/etc/adbyby_user.txt" ] ;then
cp /etc/adbyby_user.txt  /tmp/adbyby/bin/data/user.txt 2>/dev/null
fi

if [ "$run_mode" = "1" ]  ;then
echo "ipset=1">>/tmp/adbyby/bin/adhook.ini
fi
./adbyby >/dev/null 2>&1 &  
fi


iptables -t nat -w -N adbyby_chain 2>/dev/null
iptables -t nat -w -F adbyby_chain 2>/dev/null
iptables -t nat -w -C PREROUTING -p tcp -j adbyby_chain 2>/dev/null
if [ "$?" != "0" ]  ;then
iptables -t nat -w -A PREROUTING -p tcp -j adbyby_chain 2>/dev/null
fi

iptables -t nat -w -A adbyby_chain -d 192.168.0.0/16 -j RETURN

if [ "$run_mode" = "1" ]  ;then

if [ "$adb_mod" = "0" ]  ;then
#adb
sleep 2
if [ ! -f /tmp/adbyby_host.conf ] ;then
sleep 3
fi
cp -f /tmp/adbyby_host.conf /tmp/dnsmasq.d/adbyby_host.conf

rm -f /tmp/adbyby_host.conf 2>/dev/null

ipset -N adbyby_list hash:ip  2>/dev/null
iptables -t nat -A adbyby_chain -p tcp --dport 80 -m set --match-set adbyby_list dst -j REDIRECT --to-port 8118

/etc/init.d/dnsmasq restart
else
#kp
ipset -N adblock hash:ip  2>/dev/null
ipset add adblock 110.110.110.110 2>/dev/null
iptables -t nat -A adbyby_chain -p tcp --dport 80 -m set --match-set adblock dst -j REDIRECT --to-port 8118

if [ -f "/tmp/koolproxy/data/certs/ca.crt" -a "$https_en" = "1"  ] ;then
if [  "$httpsip_flag" = "1" ]  ;then
sed '/.*/s/.*/iptables -t nat -A adbyby_chain -s & -p tcp --dport 443 -m set --match-set adblock dst -j REDIRECT --to-ports 8118/' /etc/adbyby_httpsip.txt | sh
else
iptables -t nat -A adbyby_chain -p tcp --dport 443 -m set --match-set adblock dst -j REDIRECT --to-port 8118
fi
fi

cp -f /etc/adbset/adblock.conf /tmp/dnsmasq.d/adblock.conf
/etc/init.d/dnsmasq restart
fi
else
iptables -t nat -w -C adbyby_chain -p tcp --dport 80 -j REDIRECT --to-ports 8118  2>/dev/null
if [ "$?" != "0" ]  ;then
iptables -t nat -w -A adbyby_chain -p tcp --dport 80 -j REDIRECT --to-ports 8118  2>/dev/null
if [ -f "/tmp/koolproxy/data/certs/ca.crt" -a "$https_en" = "1" -a "$adb_mod" = "1" ] ;then
if [  "$httpsip_flag" = "1" ]  ;then
sed '/.*/s/.*/iptables -t nat -A adbyby_chain -s & -p tcp --dport 443 -j REDIRECT --to-ports 8118/' /etc/adbyby_httpsip.txt | sh
else
iptables -t nat -w -A adbyby_chain -p tcp --dport 443 -j REDIRECT --to-ports 8118  2>/dev/null
fi
fi
fi

fi


if [ -f "/etc/adbyby_sip.txt" ] ;then
sed '/.*/s/.*/iptables -t nat -w -I adbyby_chain -s & -j RETURN/' /etc/adbyby_sip.txt | sh
fi

if [ -f "/etc/adbyby_dip.txt" ] ;then
sed '/.*/s/.*/iptables -t nat -w -I adbyby_chain -d & -j RETURN/' /etc/adbyby_dip.txt | sh
fi


#if [ ! -z "$1"  ]  ;then
#add_mac_rules | sh
#fi

/root/adb_mon.sh &




