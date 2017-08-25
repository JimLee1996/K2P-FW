#!/bin/sh
check_time=120
check_rule_time=1440
adb_mod=`uci get adbyby.adbyby.mode 2>/dev/null`

vcount=0
while [ "1" = "1" ]  #死循环
do 
  sleep $check_time
  let vmod=vcount%10
#check rule have refresh
  if [ $vmod = 0 ] ;then 
  if [ "$adb_mod" = "1" ]  ;then
  lazy_time=`cat /tmp/koolproxy/data/rules/koolproxy.txt |grep '\[rules\]'|awk '{print $3$4}' 2>/dev/null`
  video_time=`cat /tmp/koolproxy/data/rules/koolproxy.txt |grep '\[video\]'|awk '{print $3$4}' 2>/dev/null`
  else
  lazy_time=`awk  'NR==1{print $3$4}' /tmp/adbyby/bin/data/lazy.txt 2>/dev/null`
  video_time=`awk  'NR==1{print $3$4}' /tmp/adbyby/bin/data/video.txt 2>/dev/null`
  fi
  if [ ! -z "$lazy_time" -a  ! -z "$video_time"  ]  ;then
   lazy_ok=`echo $lazy_time |grep 2016|wc -l`
   video_ok=`echo $video_time |grep 2016|wc -l`
   if [ "$lazy_ok" = "1" -o  "$video_ok" = "1"  ]  ;then
    logger -t "adbyby" "rule file is 2016,restart adbyby!"
    /etc/init.d/adbyby restart
    exit 0  
   fi
  else
        logger -t "adbyby" "rule file not found,restart adbyby!"
   /etc/init.d/adbyby restart
      exit 0
  fi
  fi
#check iptables

   if [ "$adb_mod" = "1" ]  ;then
   icount=`netstat -nautp 2>/dev/null|grep koolproxy|grep -v grep|wc -l`
   else
   icount=`netstat -nautp 2>/dev/null|grep adbyby|grep -v grep|wc -l`
   fi 
   icount2=`iptables -t nat -S|grep adbyby|wc -l `
   if [ $icount = 0 -o $icount2 -lt 3 ] ;then
   logger -t "adbyby" "iptables error,restart adbyby!"
   /etc/init.d/adbyby restart
   exit 0
   fi

#check rule file update
   let vcount=vcount+1
   if [ $vcount -gt $check_rule_time ] ;then
     vcount=0
    if [ "$adb_mod" = "1" ]  ;then
     wget  --no-check-certificate https://kprule.com/koolproxy.txt -O /tmp/koolproxy.txt -t 1 -T 5 2>/dev/null
     lazy_time2=`cat /tmp/koolproxy.txt |grep '\[rules\]'|awk '{print $3$4}' 2>/dev/null`
     video_time2=`cat /tmp/koolproxy.txt |grep '\[video\]'|awk '{print $3$4}' 2>/dev/null`
     rm -f /tmp/koolproxy.txt 2>/dev/null
    else
     wget http://update.adbyby.com/rule3/lazy.jpg  -O /tmp/lazy.txt -t 1 -T 5 2>/dev/null
     wget http://update.adbyby.com/rule3/video.jpg -O /tmp/video.txt -t 1 -T 5 2>/dev/null
     lazy_time2=`awk  'NR==1{print $3$4}' /tmp/lazy.txt 2>/dev/null`
     video_time2=`awk  'NR==1{print $3$4}'  /tmp/video.txt 2>/dev/null`
     rm -f /tmp/lazy.txt 2>/dev/null;rm -f /tmp/video.txt 2>/dev/null
    fi


     if [ ! -z "$lazy_time2" -a  ! -z "$video_time2"  ]  ;then
      if [ "$lazy_time2" != "$lazy_time" -o "$video_time2" != "$video_time"  ]  ;then
        logger -t "adbyby" "rule file refresh,restart adbyby!"
        /etc/init.d/adbyby restart
        exit 0
      fi
     fi
   fi

done

