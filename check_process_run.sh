#!/bin/bash
# just to determine the proc is existed
count=1
DEPLOY_DIR=$1
while (($count<=20))
do
	sleep 5s
	PID=`ps -ef | grep "$DEPLOY_DIR" | grep -v "grep" |grep -v "check_process"|grep -v "start_tomcat"|awk '{print $2}' | wc -l`
	#PID=`ps -ef | grep java | grep "$1" | awk '{print $2}'`
	
	if [[ $PID -gt 0 ]]
	then		
		echo "the $1 task is running"
		break
	else
		let count++
	fi
done 
if [ $count -gt 20 ]
then
	"the $1 process is not running success!!"
	exit 2
else 
	exit 0
fi

