#!/bin/bash
catalina_home=$1
catalina_base=$2
webserv_port=$3
action=$4

#fetch tomcat info from the existed file
PORT_PID=`netstat -nlpt | grep ":$webserv_port" | awk '{print $7}' | cut -d/ -f 1 | head -n 1`
echo $PORT_PID
if [[ -n $PORT_PID ]]
then
	PID_existed_1=`ps -ef|grep $PORT_PID |grep tomcat|grep $catalina_base|awk '{print $2}'`
	echo $PID_existed_1
	PID_existed=`ps -ef|grep $PORT_PID|grep -v check_tomcat|grep -v grep|grep -v netstat`
	echo $PID_existed
	if [[ -n $PID_existed ]] && [ -z $PID_existed_1 ]
	then
		echo "the port is occupied by the other determined process, please check the paramter"
		exit 2
	
	fi
fi
###export######
export CATALINA_HOME="$catalina_home"
export CATALINA_BASE="$catalina_base"
source /etc/profile
case $action in

      'stop')
       $CATALINA_HOME/bin/shutdown.sh $CATALINA_BASE
	
       ;;
       'start')
       $CATALINA_HOME/bin/startup.sh $CATALINA_BASE
	;;
esac






