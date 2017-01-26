
#!/bin/bash

#读取变量，并设置为环境变量

 while read myline  
do 
   str=`echo $myline|grep '^#'`
   
   if [ $? -eq 0 ]
   then
	continue
   fi 
   key=`echo $myline |cut -d '=' -f 1|tr -d [:space:]`
   value=`echo $myline |cut -d '=' -f 2|tr -d [:space:]`
   #key、value需要去掉空格
#   
   case $key in 
	       *skip_Package*)
			if [ X"$value" == X ]			
			then          
				echo "skip_Package is not determined,exit"
				exit 2
			else      
				#echo $value
				export skip_Package=$value
				#echo "skip_Package is $value!!"
			fi
	       ;;
	      *git_Protocol*)
		   if [ X"$value" == X ]
		   then
				echo "git_Protocol is null"
				if [ $skip_Package == "false" ]
				then
		            		echo "git_Protocol cannot be null!!!"
			        	exit 2
				fi
		    else
			
			       echo  " git_Protocol is $value"
			   
		    fi
			export git_protocol=$value
			#在最后进行Export防止上一次构建出现的脏数据，但不能保证同时构建时是否会出现问题，待定。
			export git_Protocol=$value
		 ;;
		*git_Username*)
			if [ X"$value" == X ]
			then
				echo "git_Username is null"
				if [ "$git_Protocol" == "http" ] && [ "$skip_Package" == "false" ]
				then
					echo "git_Username cannot be null when the protocol is http"
				    exit 2
				fi
		
				#echo "git_username is $value"
				
			fi
			export git_Username=$value
		;;
		*git_Passwd*)
			if [ X"$value" == X ]
			then
				echo "git_Passwd is null"
				if [ "$git_Protocol" == "http" ] && [ "$skip_Package" == "false" ]
				then
					echo "git_Passwd cannot be null when the protocol is http"
				    exit 2
				fi
			
				#echo " git_Passed is $value"
				
			fi
			export git_Passwd=$value
	    ;;
		*build_Method*)
			if [ X"$value" == X ]
			then
				echo "build_Method is null!!"				
				if [ "$skip_Package" == "false" ]
				then
					echo "build_Method cannot be null if the skip_package is false"
					exit 2
				fi
			else
				echo  "build_Method is $value"
				
			fi
			export build_Method=$value
		;;
		*build_Type*)
			if [ X"$value" == X ]
			then
				echo "build_Type is null!!"				
				if [ "$skip_Package" == "false" ] && [ "$build_Method" == "mvn" ]
				then
					echo "build_Method cannot be null if the skip_package is false"
					exit 2
				fi
			
				#echo $value				
			fi
			echo "build_type is $value"
			export build_Type=$value
		;;
		*build_Group*)
			if [ X"$value" == X ]
			then
				echo "build_Group is null!!"				
				if [ "$skip_Package" == "false" ] && [ "$build_Method" == "mvn" ]
				then
					echo "build_Group cannot be null if the skip_package is false"
					exit 2
				fi
			else
				echo "build_Group is  $value"				
			fi		
			export build_Group=$value
		;;
		*svn_Src_Dir*)
			if [ X"$value" == X ]
			then
				echo "svn_Src_Dir cannot be null,exit now!!"
				exit 2
			else
				echo "svn_Src_Dir is $value"
				export svn_Src_Dir=$value
			fi
		;;
		*rsync_Dst*)
			if [ X"$value" == X ]
			then
				echo "rsync_Dst cannot be null,exit now!!"
				exit 2
			else
				echo "rsync_Dst is $value"
				export rsync_Dst=$value
			fi		
		;;
		*buildScript_path*)
		     if [  X"$value" == X ]
			 then
			 	echo "buildScript_path cannnot be null,exit now!!"
				exit 2
			 else
				 echo "buildScript_path is $value"
				 export buildScript_path=$value
			  fi
		;;
		*depency_Env*)
				echo "depency_Env is $value!!"			
				export depency_Env=$value			
		;;
		*websrv_Type*)
			if [ X"$value" == X ]
			then
				echo "websrv_Type cannot be null,exit now!!"
				exit 2
			else
				echo "websrv_Type is $value" 
				export websrv_Type=$value
			fi	
		;;
		*websrv_Port*)
			if [ X"$value" == X ]
			then
				if [ "$websrv_Type" == "tomcat" ]
				then
					echo "websrv_Port cannot be null,exit now!!"
					exit 2
				fi
			fi
			echo " websrv_Port is $value"
			export websrv_Port=$value
		;;
		*catalina_Base*)
			if [ X"$value" == X ]
			then
				if [ "$websrv_Type" == "tomcat" ]
				then
					echo "catalina_Base cannot be null,exit now!!"
					exit 2
				fi
			fi
			echo " catalina_Base is $value "
			export catalina_Base=$value
		;;
		*catalina_Home*)
			if [ X"$value" == X ]
			then
				if [ "$websrv_Type" == "tomcat" ]
				then
					echo "catalina_Home cannot be null,exit now!!"
					exit 2
				fi
			fi
			echo " catalina_Hom is $value "
			export catalina_Home=$value
		;;	
		*tomcat_Version*)
			if [ X"$value" == X ]
                        then
                                if [ "$websrv_Type" == "tomcat" ]
                                then
                                        echo "tomcat_Version cannot be null,exit now!!"
                                        exit 2
                                fi
                        fi
                        echo " tomcat_Version is $value "
                        export tomcat_Version=$value
                ;;	
		*ssh_Method*)
			if [ X"$value" == X ]
			then
				echo "ssh_Method cannot be null"
				exit 2
			fi	
			echo "ssh_Method is $value"
			export ssh_Method=$value
		;;
		*ssh_Username*)
			if [ X"$value" == X ]
			then
				if [ "$ssh_Method" == "passwd" ]
				then
					echo "ssh_username cannot be null,exit now!!"
					exit 2
			        fi
			fi
			echo " ssh_Username is $value"
			export ssh_Username=$value		
		;;
		*ssh_Passwd*)
			if [ X"$value" == X ]
			then
				if [ "$ssh_Method" == "passwd" ]
				then
					echo "ssh_passwd cannot be null,exit now!!"
					exit 2
				fi
			fi
			echo " ssh_Passwd is $value"
			export ssh_Passwd=$value	
		;;
		*ssh_Port*)
			if [ X"$value" == X ]
			then
				export ssh_Port=22
			else
				 export ssh_Port=$value
			fi			
		;;
		*server_List*)
			if [ X"$value" == X ]
			then
				echo "server_List cannot be null"
				exit 2
			fi	
			echo "server_List is $value"
			export server_List=$value		
		;;
		
		*git_Rep*)
			if [ X"$value" == X ]
			then
				echo "git_rep cannot be null"
				exit 2
			fi
			echo "git_Rep is $value!!"
			export git_Rep=$value

			if [ $? -ne 0 ]
			then 
				echo "export Rep value not success!!"
			fi
			echo $git_Rep
		
		;;
		*git_Branch*)
			if [ X"$value" == X ]
			then
				echo "git_Branch cannot be null"
				exit 2
			fi
			echo "git_Branch is $value"
			export git_Branch=$value
		;;	
		*git_Name*)
			if [ X"$value" == X ]
			then
				echo "git_Name cannot be null"
				exit 2
			fi
			echo "git_Name is $value"
			export git_Name=$value	
		;;	
		*java_Version*)
			echo "java_version is $value"
			export java_Version=$value
		;;
		*java_Path*)
			echo "java_Path is $value"
			export java_Path=$value
		;;		
		esac	
done<$1
#set +x 
: > $buildScript_path/log
#打包逻辑
#判断是否执行源码拉取及编译阶段
if [ "$skip_Package" == "false" ]
then
	rm -rf $git_Name
	if [ "$git_Protocol" == 'ssh' ]
	then
		echo "please make sure that current user has the corrected ssh key !!"

		set -e
		git clone $git_Rep
		local_dir=`pwd`
		echo $local_dir
		echo $git_Name
		cd $git_Name
		git checkout $git_Branch
		set +e
		
	#待解决问题，可能需要去掉该方式。或者用户直接提供一个带用户名和密码的url串	
	elif [ "$git_protocol" == 'http' ]
	then
		set -e
		git clone $git_Rep 
		local_dir=`pwd`
		echo $local_dir
		echo $git_Name
		cd $git_Name
		git checkout $git_Branch
		set +e	
	fi
	chmod 777 build.sh
	source /etc/profile
	sh build.sh -T=$build_Method -P=$build_Type -AB=$build_Group	
fi
set -e
cd $svn_Src_Dir
src_dir=`pwd`
tar -czf $git_Name.tar.gz  *
set +e

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


#分发逻辑

 server=$(func_splite $server_List ',')
        case $websrv_Type in
                        'static')
                                for i in ${server[@]}
                                    do
										#scp transfer
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "mkdir -p /home/$ssh_Username/buildScript"
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/env_Pre.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
                                        sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/start_Process.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
                                        sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/check_Process_kill.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
                                        sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/check_Process_run.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
																				
										#ssh env clean and process status check
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo sh /home/$ssh_Username/buildScript/env_Pre.sh $ssh_Username $rsync_Dst $java_Version $java_Path /etc/profile"
										if [ $? -ne 0 ] 
                                        then
                                                echo "$i: env prepare occur error,please check the process status !!"
                                                exit 2
                                        fi
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo sh /home/$ssh_Username/buildScript/check_process_kill.sh $rsync_Dst"

                                        if [ $? -ne 0 ] 
                                        then
                                                echo "$i:kill process occur error,please check the process status !!"
                                                exit 3
                                        fi
										
										#ssh process start
                                        sshpass -p $ssh_Passwd scp -P $ssh_Port $src_dir/$git_Name.tar.gz $ssh_Username@$i:/home/$ssh_Username/$rsync_Dst/

                                        if [ $? -ne 0 ] 
                                        then
                                                echo "$i:scp process occur error,please concact with zhenglin !!"
                                                exit 4
                                        fi
										
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo sh /home/$ssh_Username/buildScript/start.sh $ssh_Username $rsync_Dst $git_Name $jacoco_start_dir"									

                             			if [ $? -ne 0 ] 
                                        then
                                                echo "$i:start process occur error,please concact with zhenglin !!"
                                                exit 5
                                        fi                                      
                                   done
								    
                                ;;

                        'tomcat')
                                for i in ${server[@]}
                                    do
										#prepare the dir and install jdk and tomcat 
										
								((	     sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "mkdir -p /home/$ssh_Username/buildScript"
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "rm -rf /home/$ssh_Username/buildScript/*"
										set -e
									    sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/tomcat_env_Pre.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/                
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/env_clean.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/                                                         
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/check_tomcat.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/ 
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/start_tomcat.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/ 
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/check_process_kill.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
										sshpass -p $ssh_Passwd scp -P $ssh_Port $buildScript_path/check_process_run.sh $ssh_Username@$i:/home/$ssh_Username/buildScript/
										set +e
										#clean the env 							
										 sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sh /home/$ssh_Username/buildScript/env_clean.sh $ssh_Username $rsync_Dst/webapps/ROOT $java_Path"			
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo sh /home/$ssh_Username/buildScript/tomcat_env_Pre.sh $ssh_Username $rsync_Dst/webapps/ROOT $java_Version $java_Path $catalina_Base /etc/profile $tomcat_Version"
										if [ $? -ne 0 ] 
                                        then
                                                echo "$i: tomcat env prepare occur error, please check it !"
                                                exit 2
                                        fi	
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo /home/$ssh_Username/buildScript/check_tomcat.sh $catalina_Home $catalina_Base $websrv_Port stop"
					if [ $? -ne 0 ]
                                        then
                                                echo "check the tomcat status occur error,maybe the port is occuping!!"
                                                exit 3
                                        fi
										
                                        sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo sh /home/$ssh_Username/buildScript/check_process_kill.sh $rsync_Dst"
                                        if [ $? -ne 0 ] 
                                        then
                                                echo "$i:kill process occur error,please check the process status !!"
                                                exit 4
                                        fi

                                        sshpass -p $ssh_Passwd scp -P $ssh_Port $src_dir/$git_Name.tar.gz $ssh_Username@$i:/home/$ssh_Username/$rsync_Dst/webapps/ROOT
                                        if [ $? -ne 0 ] 
                                        then
                                                echo "$i: scp process occur error,please concact with zhenglin !!"
                                                exit 5
                                        fi
										sshpass -p $ssh_Passwd ssh -p $ssh_Port $ssh_Username@$i "sudo  /home/$ssh_Username/buildScript/start_tomcat.sh $ssh_Username $catalina_Home $catalina_Base $websrv_Port $git_Name"
										if [ $? -ne 0 ] 
                                        then
                                                echo "$i:the tomcat is start failed,please check it!!"
                                                exit 6
                                        fi                                       );echo $i:$?>>$buildScript_path/log)&
                                   done
				   wait
			############check the job status in differ IP##############################
				fail_num=`cat $buildScript_path/log | grep -v ':0'|grep -v " "|wc -l`
				succed_num=`cat $buildScript_path/log | grep ':0'|grep -v " "|wc -l`
				failed_ip_list=`cat $buildScript_path/log |grep -v ':0'|cut -d ":" -f 1`
				succed_ip_list=`cat $buildScript_path/log |grep ':0'|cut -d ":" -f 1`
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
				else	
					echo "all of the deployment jobs are sucessful!"
					echo "the succed ip list is $succed_ip_list"
				fi 
                                ;;
                 esac
