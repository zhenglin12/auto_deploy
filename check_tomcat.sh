#!/bin/bash
rsync_Dst=`dirname $(dirname $1)`
webserv_port=$2
action=$3

#fetch tomcat info from the existed file
PORT_PID=`netstat -nlpt | grep ":$webserv_port" | awk '{print $7}' | cut -d/ -f 1 | head -n 1`
echo $PORT_PID
if [[ -n $PORT_PID ]]
then
	PID_existed_1=`ps -ef|grep $PORT_PID |grep tomcat|grep $rsync_Dst|awk '{print $2}'`
	echo $PID_existed_1
	PID_existed=`ps -ef|grep $PORT_PID|grep -v check_tomcat|grep -v grep|grep -v netstat`
	echo $PID_existed
	if [[ -n $PID_existed ]] && [ -z $PID_existed_1 ]
	then
		echo "the port is occupied by the other determined process, please check the paramter"
		exit 2
	
	fi
fi
###analyze the catalina home
PID=`ps -ef|grep $rsync_Dst|grep tomcat|grep -v check_tomcat|awk '{print $2}'`
if [[ -z $PID ]]
then

	if [ -s "/home/jenkins/tomcat/.tomcat_${webserv_port}" ]
	then
		 CATALINA_BASE=`grep CATALINA_BASE /home/jenkins/tomcat/.tomcat_${webserv_port} | cut -d= -f 2`
		 CATALINA_HOME=`grep CATALINA_HOME /home/jenkins/tomcat/.tomcat_${webserv_port} | cut -d= -f 2`
		 JAVA_HOME=`grep JAVA_HOME /home/jenkins/tomcat/.tomcat_${webserv_port} | cut -d= -f 2`
	else
		echo "the process is not running, cannot find Pid info, please start the process and then do the jenkins job!!"
		exit 2
	fi
	if [ $? -ne 0 ]
	then
		exit 2
	fi
else
	CATALINA_BASE=`ps -o cmd --no-heading $PID | tr ' ' '\n' | grep catalina.base | cut -d= -f 2`
	if [[ -z $CATALINA_BASE ]]
	then
		echo "cannot fetch the tomcat running info, please contact with zhenglin!!"
		exit 2
	else

		echo "CATALINA_BASE=$CATALINA_BASE" >  "/home/jenkins/tomcat/.tomcat_${webserv_port}"
	fi
	CATALINA_HOME=`ps -o cmd --no-heading $PID | tr ' ' '\n' | grep catalina.home | cut -d= -f 2`
	if [[ -z $CATALINA_HOME ]]
	then
		echo "cannot fetch the tomcat running info, please contact with zhenglin!!!"
		exit 2
	else
		 echo "CATALINA_HOME=$CATALINA_HOME" >>  "/home/jenkins/tomcat/.tomcat_${webserv_port}"

	fi
	JAVA_HOME=`ps -o cmd --no-heading $PID | tr ' ' '\n' | grep java.home | cut -d= -f 2`
	if [[ -z $JAVA_HOME ]]
	then
		echo "cannot fetch the java_home , please contact with zhenglin!!"
		#exit 2
	else
		echo "JAVA_HOME=$JAVA_HOME" >  "/home/jenkins/tomcat/.tomcat_${webserv_port}"
	fi
fi

###export######
export CATALINA_HOME="$CATALINA_HOME"
export CATALINA_BASE="$CATALINA_BASE"
source /etc/profile
case $action in

      'stop')
       $CATALINA_HOME/bin/shutdown.sh $CATALINA_BASE
	
       ;;
       'start')
       $CATALINA_HOME/bin/startup.sh $CATALINA_BASE
	;;
esac
