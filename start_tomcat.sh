#!/bin/bash
#determine the paramter
ssh_Username=$1
catalina_home=$2
catalina_base=$3
dst_dir=$3/webapps/ROOT
webserv_port=$4
git_Name=$5
sudo cp /home/$ssh_Username/$dst_dir/$git_Name.tar.gz $dst_dir/
sudo tar -xzf $dst_dir/$git_Name.tar.gz -C $dst_dir/
if [ $? -ne 0 ] 
then
	echo "untar  process occur error,please concact with zhenglin !"                           
	exit 2
fi

sed -i 's/Connector port="8080"/Connector port='\"$webserv_port\"'/' $catalina_base/conf/server.xml
if [ $? -ne 0 ]
then 
	echo "revise the server.xml file error,please make sure the parameter!!"
	exit 2
fi
source /etc/profile
sudo sh /home/$ssh_Username/buildScript/check_tomcat.sh $catalina_home $catalina_base $webserv_port start
sudo sh /home/$ssh_Username/buildScript/check_process_run.sh $catalina_base
if [ $? -ne 0 ] 
then
	echo "start the process error,please check the log !! "
	exit 2
fi

