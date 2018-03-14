#!/bin/bash
# just to determine the proc is existed
set -x
dir_source=$1
PID=`ps -ef|grep $dir_source|grep -v "grep"|grep -v "check_process"|awk '{print $2}'`

if [[ -z $PID ]];then
    echo "The task is not running ! "
else
     echo $1" pid: $PID"	 
		echo ${PID[@]}
		echo "------kill the task!------"
		for id in ${PID[*]}
		    do
			echo ${id}
			
			kill -9 ${id}       
			    if [ $? -eq 0 ]
			    then
			    	echo "task is killed ..."
			    else
				echo "kill task failed "

				sleep 2
				kill -9 ${id} 
				    if [$? -ne 0]
				    then
					echo "kill task failed twice, please check the $1 process status!!"
					exit 2
				    fi
			    fi
            done
fi
set +x



