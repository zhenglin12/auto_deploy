#!/bin/bash
#paramter list
ssh_Username=$1
dst_dir=$2
jacoco_start_dir=$4
script_Path=$3
if [ "$ssh_Username"X == X ] || [ "$dst_dir"X == X ]
then 
	echo "the paramter is null, please check the script!!"
	exit 2
fi									
sudo cp /home/$ssh_Username/$dst_dir/package.tar.gz $dst_dir/
sudo tar -xzf $dst_dir/package.tar.gz -C $dst_dir
if [ $? -ne 0 ] 
then
	echo "untar  process occur error,please concact with zhenglin !! "
	exit 2
fi
sudo rm -rf $dst_dir/package.tar.gz

if [[ -n $jacoco_start_dir ]]
then
	sudo cp -rf $jacoco_start_dir $dst_dir/bin/start.sh
fi
sudo bash  -l  $dst_dir/bin/start.sh
sudo sh $script_Path/check_process_run.sh $dst_dir
if [ $? -ne 0 ] 
then
	echo "start the process error,please check the log !! "
	exit 2
fi
