#!/bin/bash
#adapt for the jenkins job deployment

set -x
if [[ -z $passwd ]]
then
   ssh_Passwd='jenkins'
fi
if [[ -z $username ]]
then
    ssh_Username='jenkins'
fi
ssh_Port=22
local_script=/home/jenkins/buildScript/scriptV2/auto_deploy
#first check the input paramters validition
echo 'shell paramters is as follows'
echo $#
echo "##############check the paramters############"
for i in "$@"
do
        para=$i
	echo $para

        case $para in
              -S*)
                        src_dir=`echo $para |cut -d'='  -f 2`
						if [ "$src_dir"x == x ]
						then
							echo 'src_dir' cannot be null!!
							exit 2
						else
							echo 'src_dir' is $src_dir!!
						fi
             ;;
              -D*)
                        rsync_Dst=`echo $para |cut -d'='  -f 2`
						if [ "$rsync_Dst"x == x ]
						then
							echo 'rsync_Dst' cannot be null!!
							exit 2
						else
						    rsync_Dst=`echo  ${rsync_Dst//\/\//\/}`
							echo 'rsync_Dst'  is $rsync_Dst!!
						fi
             ;;
              -P*)
						webserv_port=`echo $para |cut -d'='  -f 2`
						;;
		      -T*)
						webserv_Type=`echo $para |cut -d'='  -f 2`
						if [ "$webserv_Type"x == x ]
						then
							echo 'webserv_Type' cannot be null!!
							exit 2
						else
							echo 'webserv_Type' is $webserv_Type!!
							if [ $webserv_Type == "tomcat" ]
							then
								if [ "$webserv_port"x == x ]
								then
									echo 'webserv_port' cannot be null in webservice!!
									exit 2
								fi
							fi
						fi
			;;
		      -L*)
						set -x
						echo $para
						server_list=`echo $para |cut -d'='  -f 2`
						if [ "$server_list"x == x ]
						then
							echo  'server_list' cannot be null!!!
							exit 2
						else
							echo 'server_list'  is $server_list !!
						fi
						set +x
			;;
		      -H*)
						proxy_host=`echo $para |cut -d'='  -f 2`
			;;

		      -M*)
						deploy_mode=`echo $para |cut -d'='  -f 2`
						if [ "$deploy_mode"x == x ]
						then
							echo 'deploy_mode' cannnot be null!!
							exit 2
						else
							echo 'deploy_mode'  is $deploy_mode !!
							if [ $deploy_mode == "proxy" ]
							then
								if [ "$proxy_host"x == x ]
								then
									echo 'proxy_host' cannot be null in proxy mode!!
									exit 2
								fi
							fi
						fi
		    ;;
	esac
done

set -e
local_dir=`pwd`
echo $local_dir
cd $local_dir
cd $src_dir

src_dir=`pwd`
set +e
tar -czf  package.tar.gz  *

#解析IP函数
func_splite(){
num=`echo $1|awk -F$2 '{print NF-1}'`
if [ $num == 0 ]
then
        server[0]=$1
else
        i=1 
        while((1==1))  
        do  
        split=`echo $1|cut -d $2 -f$i`  
                if [ "$split" != "" ]  
                        then  
                             ((i++))                               
                             server[i-2]=$split 
                else
                        break  
                fi  
        done 
fi
echo ${server[@]}
}


func_ssh_login(){
if [ $ssh_Login == 'ssh-key' ]
then
    ssh -p $ssh_Port $ssh_Username@$1 "$2"
    if [ $? -ne 0 ]
    then
        return 7
    fi
else
    sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$1 "$2"
    if [ $? -ne 0 ]
    then
        return 7
    fi
fi
}

func_scp_login(){
if [ $ssh_Login == 'ssh-key' ]
then
    scp -p $ssh_Port $1 $ssh_Username@$2:$3
    if [ $? -ne 0 ]
    then
        return 8
    fi
else
    sshpass -p $ssh_Passwd scp -p $ssh_Port  $1 $ssh_Username@$2:$3
     if [ $? -ne 0 ]
    then
        return 8
    fi
fi
}

func_staticSsh(){
                                        ##为root设置默认的home目录，确定ssh登录方式。
                                        set -x
                                        if [ $ssh_Username == 'root' ]
                                        then
                                            #for tesing if ssh-key is vaild
                                            ssh_Login='ssh-key'
                                            script_Path='/home/jenkins/buildScript'
                                        else
                                            script_Path="/home/$ssh_Username/buildScript"
                                            sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "pwd"
                                            if [ $? -ne 0 ]
                                            then
                                                echo "user-passwd login failed!!"
                                                ssh_Login='ssh-key'
                                            else
                                                ssh_Login='user-passwd'
                                            fi
                                        fi

                                        if [ $ssh_Login == 'ssh-key' ]
                                        then
                                            ssh -p $ssh_Port $ssh_Username@i "pwd"
                                            if [ $? -ne 0 ]
                                            then
                                                 echo "ssh authorization is failed, please check the ssh rsa certificate or the ssh username and passwd !!"
                                                 return 6
                                            fi
                                        fi
										func_ssh_login $i "mkdir -p $script_Path"
										func_ssh_login $i "rm -rf $script_Path"
										set -e
										func_scp_login $local_script/script.tar.gz $i $script_Path
										func_ssh_login $i "tar -xzvf $script_Path/script.tar.gz -C $script_Path"
										set +e
                                        #ssh clean the file
                                        func_ssh_login $i "sh $script_Path/env_clean.sh $ssh_Username $rsync_Dst"
                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i: env prepare occur error,please check the process status !!"
                                                return 2
                                        fi
                                        func_ssh_login $i "sudo sh $script_Path/check_process_kill.sh $rsync_Dst"

                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i:kill process occur error,please check the process status !!"
                                                return 3
                                        fi
										#ssh process start
										func_scp_login $src_dir/package.tar.gz $i /home/$ssh_Username/$rsync_Dst/

                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i:scp process occur error,please concact with zhenglin !!"
                                                return 4
                                        fi
                                        func_ssh_login $i "sudo sh $script_Path/start_process.sh $ssh_Username $rsync_Dst $script_Path $jacoco_start_dir"
#
                             			if [ $? -ne 0 ]
                                        then
                                                echo "$i:start process occur error,please concact with zhenglin !!"
                                                return 5
                                        fi
                                        set +x

                                        }

func_tomcatSsh(){
                                        set -x


										func_ssh_login $i "mkdir -p $script_Path"
										func_ssh_login $i "rm -rf $script_Path/*"
										set -e
									    func_scp_login $local_script/script.tar.gz $i $script_Path
									    func_ssh_login $i "tar -xzvf $script_Path/script.tar.gz -C $script_Path"
										set +e
										#clean the env
										func_ssh_login $i "sh $script_Path/env_clean.sh $ssh_Username $rsync_Dst"
                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i: tomcat env prepare occur error, please check it !"
                                                return 2
                                        fi
										func_ssh_login $i "sudo $script_Path/check_tomcat.sh $rsync_Dst $websrv_Port stop"
										if [ $? -ne 0 ]
                                        then
                                                echo "check the tomcat status occur error,maybe the port is occuping!!"
                                                return 3
                                        fi
                                        func_ssh_login $i "sudo sh $script_Path/check_process_kill.sh $(dirname $(dirname $rsync_Dst))"
                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i:kill process occur error,please check the process status !!"
                                                return 4
                                        fi
                                        func_scp_login $src_dir/package.tar.gz $i /home/$ssh_Username/$rsync_Dst/
                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i: scp process occur error,please concact with zhenglin !!"
                                                return 5
                                        fi
                                        func_ssh_login $i "sudo $script_Path/check_tomcat.sh $rsync_Dst $websrv_Port start"
										if [ $? -ne 0 ]
                                        then
                                                echo "$i:the tomcat is start failed,please check it!!"
                                                return 6
                                        fi
                                        func_ssh_login $i "sudo sh $script_Path/check_process_run.sh $(dirname $(dirname $rsync_Dst))"
                                        if [ $? -ne 0 ]
                                        then
                                                echo "$i:the tomcat is start failed,please check it!!"
                                                return 6
                                        fi
                                        set +x
}

func_checkRes(){
								fail_num=`cat $1| grep -v ':0'|grep -v " "|wc -l`
								succed_num=`cat $1 | grep ':0'|grep -v " "|wc -l`
								failed_ip_list=`cat $1 |grep -v ':0'|cut -d ":" -f 1`
								succed_ip_list=`cat $1 |grep ':0'|cut -d ":" -f 1`
								if [ $fail_num -gt 0 ] && [ $succed_num -gt 0 ]
								then
									echo "this deply job  is failed!!"
									echo "the failed ip list is $failed_ip_list"
									echo "the succed ip list is $succed_ip_list"
									exit 1
								elif [ $fail_num -gt 0 ]
								then
									echo "this deply job  is failed!!"
                    				echo "the failed ip list is $failed_ip_list"
                    				exit 1
								elif [ $fail_num -eq 0 ] && [ $succed_num -eq 0 ]
								then
									echo "the result callback has some problem,please check the console !!"
									exit 2
								else
									echo "all of the deployment jobs are sucessful!"
									echo "the succed ip list is $succed_ip_list"
								fi
}

#分发逻辑
 server=$(func_splite ${server_List} ',')
 case $websrv_Type in
                        'static')
                                for i in ${server[@]}
								do
									#scp transfer
									(func_staticSsh;echo $i:$?>>$src_dir/deploy.log)&
								done
								wait
							############check the job status in differ IP##############################
								func_checkRes $src_dir/deploy.log
				        ;;
                        'tomcat')
                                for i in ${server[@]}
								do
										#prepare the dir and install jdk and tomcat
								(func_tomcatSsh;echo $i:$?>>$src_dir/deploy.log)&
                                done
				   				wait
						############check the job status in differ IP##############################
								func_checkRes ${src_dir}/deploy.log
		                ;;
		                esac
set +x
