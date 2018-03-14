#!/usr/bin/env bash
#先清理环境，一旦出现异常，则退出
#通过key=value的方式传递参数，保证参数传入的正确性。
for i in "$@"
do
        para=$i
        echo $para
        case $para in
        -J*)
                        java_IsRequired=`echo $para |cut -d'='  -f 2`
                                                if [ "$java_IsRequired"x == x ]
                                                then
                                                        echo "java_IsRequired' cannot be null!!"
                                                        exit 2
                                                else
                                                        echo "java_IsRequired is $java_IsRequired!!"
                                                fi
                        ;;
		-V*)
                        java_Version=`echo $para |cut -d'='  -f 2`
                         echo "java_Version is $java_Version!!"

						;;
		-P*)
                        java_Path=`echo $para |cut -d'='  -f 2`
                        echo "java_Path is $java_Path!!"

                        ;;
		-Y*)
                        python_IsRequired=`echo $para |cut -d'='  -f 2`
                                                if [ "$python_IsRequired"x == x ]
                                                then
                                                        echo "python_IsRequired cannot be null!!"
                                                        exit 2
                                                else
                                                        echo "python_IsRequired is $python_IsRequired!!"
                                                fi
                        ;;
		-E*)
                        python_Version=`echo $para |cut -d'='  -f 2`
                        echo "python_Version is $python_Version!!"

                        ;;
		-T*)
                        python_Path=`echo $para |cut -d'='  -f 2`
                        echo "python_Path is $python_Path!!"
                        ;;
                -C*)
                        cmake_IsRequired=`echo $para |cut -d'='  -f 2`
                                                if [ "$cmake_IsRequired"x == x ]
                                                then
                                                        echo "cmake_IsRequired cannot be null!!"
                                                        exit 2
                                                else
                                                        echo "cmake_IsRequired is $cmake_IsRequired!!"
                                                fi
                        ;;
                -K*)
                        cmake_Version=`echo $para |cut -d'='  -f 2`
                        echo "cmake_Version is $cmake_Version!!"
                        ;;
                -M*)
                        cmake_Path=`echo $para |cut -d'='  -f 2`
                        echo "cmake_Path is $cmake_Path!!"
                        ;;
		-R*)
                        rpm_IsRequired=`echo $para |cut -d'='  -f 2`
                                                if [ "$rpm_IsRequired"x == x ]
                                                then
                                                        echo "rpm_IsRequired cannot be null!!"
                                                        exit 2
                                                else
                                                        echo "rpm_IsRequired is $rpm_IsRequired!!"
                                                fi
                        ;;
		-L*)
                        rpm_List=`echo $para |cut -d'='  -f 2`
                        echo "rpm_List is $rpm_List!!"
                        ;;
		-F*)
                        file_Path=`echo $para |cut -d'='  -f 2`
                        			if [ "$file_Path"x == x ]
                                                then
                                                        echo "file_Path cannot be null!!"
                                                        exit 2
                                                else
                                                        echo "file_Path is $file_Path!!"
                                                fi
                        ;;
				esac
done
#function to install the cmake
func_cmkInstall(){
	yum install -y gcc gcc-c++ make automake
	echo "###install the cmake $cmake_Version automtically in the $cmake_Path####"
	mkdir -p $cmake_Path
	set -e
	rm -rf cmake$cmake_Version*
	func_wgetInstall
	echo "######begin to install the cmake ##########"
	wget http://10.9.0.149/cmake$cmake_Version.tar.gz >/dev/null 2>&1
	tar -xzf  cmake$cmake_Version.tar.gz
	rm -rf cmake$cmake_Version.tar.gz
	set +e
	mv cmake$cmake_Version* cmake$cmake_Version
	set -e
	cd cmake$cmake_Version
	./bootstrap >/dev/null 2>&1
	gmake >/dev/null 2>&1
	gmake install >/dev/null 2>&1
	set +e
}
#function to install wget
func_wgetInstall(){
	wget --help >wget.txt 2>&1
	if_installed=`cat wget.txt|grep "--version"`
	if [ "$if_installed"X == X ]
	then
		echo "the wget is not installed, begin to install the wget!!"
		yum install -y wget >/dev/null 2>&1
	fi
}
#function to splite the , into space
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
#function to check if the rpm package is installed and then install the required package automically
func_rpm(){

rpm -qa $1 >rpmQa.log 2>&1
if_installed=`cat rpmQa.log|grep $1`
if [ "$if_installed"X == X  ]
then
	yum install -y $1  >$1.log 2>&1
          
          if  [ $? == 0 ];then
             echo "$1 install is success!"
          else
                echo "$1 is not in the systerm Packages,installation is failed!!"
                return 2
          fi
fi
}

#安装环境,一旦出现异常，则退出
#检查环境是否安装，如果安装，则跳过安装
source $file_Path
local_dir=`pwd`
#JDK install

if [ $java_IsRequired == true ] && [ "$java_Path"X != X ] && [ "$java_Version"X != X  ]
then
		java -version >java.txt 2>&1
		chmod 777 java.txt

		if_Jdk=`cat $local_dir/java.txt|grep 'Java(TM) SE Runtime Environment'`
		if_version=`cat $local_dir/java.txt|grep  $java_Version`
		if [ "$if_Jdk"X != X ] && [ "$if_version"X != X ]
		then
				echo "the required jdk is installed !!"
		elif [ "$if_Jdk"X != X ]
		then
				echo "###install the jdk $java_Version automtically in the $java_Path####"
				set -e
				mkdir -p $java_Path
				#to determine the path
				 cd $java_Path
				 rm -rf jdk$java_Version
				func_wgetInstall
				echo "######begin to install the java ##########"
				 wget http://10.9.0.149/jdk$java_Version.tar.gz >/dev/null 2>&1
				 tar -xzf  jdk$java_Version.tar.gz
				 rm -rf jdk$java_Version.tar.gz
				 mv jdk$java_Version* jdk$java_Version

				#symbolic link
				 rm -rf $java_Path/default
				 ln -s $java_Path/jdk$java_Version $java_Path/default
				 echo "revise the /etc/profile !!"
				 sed -i '/JAVA_HOME/d' $file_Path
				 sed -i '/JRE_HOME/d' $file_Path
				 sed -i '$a export JAVA_HOME='$java_Path'/default' $file_Path
				 sed -i '$a export JRE_HOME='$java_Path'/default/jre' $file_Path
				 sed -i '$a export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH' $file_Path
				 sed -i '$a export PATH=$JAVA_HOME/bin:$PATH' $file_Path
				 source $file_Path
				 set +e
				#修改/etc/profile文件
		else
				set -e
				echo "###install the jdk $java_Version automtically in the $java_Path####"
				#to determine the path
				 cd $java_Path
				rm -rf jdk$java_Version
				wget --help >wget.txt 2>&1
				if_installed=`cat wget.txt|grep "--version"`
				if [ "$if_installed"X == X ]
				then
					echo "the wget is not installed, begin to install the wget!!"
					yum install -y wget >/dev/null 2>&1
				fi
				 echo "######begin to install the java ##########"
				 wget http://10.9.0.149/jdk$java_Version.tar.gz >/dev/null 2>&1
				 tar -xzf  jdk$java_Version.tar.gz
				 rm -rf jdk$java_Version.tar.gz
				 mv jdk$java_Version* jdk$java_Version
				 rm -rf $java_Path/default
				 ln -s $java_Path/jdk$java_Version $java_Path/default
				 echo "revise the JAVA_HOME in /etc/profile"
				 sed -i '/JAVA_HOME/d' $file_Path
				 sed -i '/JRE_HOME/d' $file_Path
				 sed -i '$a export JAVA_HOME='$java_Path'/default' $file_Path
				 sed -i '$a export JRE_HOME='$java_Path'/default/jre' $file_Path
				 sed -i '$a export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH' $file_Path
				 sed -i '$a export PATH=$JAVA_HOME/bin:$PATH' $file_Path
				 source $file_Path
				set +e
		fi
elif [ "$java_Path"X == X ] || [ "$java_Version"X == X  ] && [ $java_IsRequired == 'true' ]
then
	echo "the java variable is not corrected,please check it!! "
	exit 2
else
	echo "the JDK is not required,skip the install step!!"
fi

cd $local_dir
#cmake install
if [ $cmake_IsRequired == 'true' ] && [ "$cmake_Path"X != X ] && [ "$cmake_Version"X != X  ]
then
		
		cmake -version >cmake.txt 2>&1
		chmod 777 cmake.txt

		if_Cmk=`cat $local_dir/cmake.txt|grep 'cmake version'`
		if_version=`cat $local_dir/cmake.txt|grep  $cmake_Version`
		set -e
		if [ "$if_Cmk"X != X ] && [ "$if_version"X != X ]
		then
				echo "the required cmake is installed !!"
		elif [ "$if_Cmk"X != X ]
		then
				#移除旧版本，安装新版本
				yum remove cmake
				func_cmkInstall
					
		else

				func_cmkInstall
		fi

elif [ "$cmake_Path"X == X ] || [ "$cmake_Version"X == X  ] && [ $cmake_IsRequired == 'true' ]
then
	echo "the cmake variable is not corrected,please check it!! "
	exit 2
else
	echo "the cmake is not required,skip the install step!!"
fi
set +e

#python install
cd $local_dir
if [ $python_IsRequired == 'true' ] && [ "$python_Path"X != X ] && [ "$python_Version"X != X  ]
then
		python --version >python.txt 2>&1
		chmod 777 python.txt

		if_Pyt=`cat $local_dir/python.txt|grep 'Python'`
		if_version=`cat $local_dir/python.txt|grep  $python_Version`
		if [ "$if_Pyt"X != X ] && [ "$if_version"X != X ]
		then
				echo "the required python is installed !!"
		else
				echo "###install the python $python_Version automtically in the $python_Path####"
				
				mkdir -p $python_Path
				#to determine the path
				 cd $python_Path
				 rm -rf Python$python_Version*
				 func_wgetInstall
				 echo "######begin to install the python ##########"
				 set -e
				 wget http://10.9.0.149/Python$python_Version.tar.gz >/dev/null 2>&1
				 tar -xzf  Python$python_Version.tar.gz
				 rm -rf Python$python_Version.tar.gz
				 set +e
				 mv Python$python_Version* Python$python_Version
				
				 rm -rf $python_Path/default
				 set -e
				 mkdir -p  $python_Path/default
				 cd Python$python_Version
				 ./configure --prefix=$python_Path/default >/dev/null 2>&1
				 make >/dev/null 2>&1
				 make install >/dev/null 2>&1
				 mv /usr/bin/python /usr/bin/python_old
				 ln -s $python_Path/default/bin/python /usr/bin/python
				 set +e
		fi
elif [ "$python_Path"X == X ] || [ "$python_Version"X == X  ] && [ $python_IsRequired == 'true' ]
then
	echo "the python variable is not corrected,please check it!! "
	exit 2
else
	echo "the python is not required,skip the install step!!"
fi

cd $local_dir
#yum install rpm list
#先进行解析传入的参数，将其变为数组
if [ $rpm_IsRequired == 'true' ] && [ "$rpm_List"X != X ] 
then	
	echo " " >$local_dir/rpm.log
	rpm_Lists=$(func_splite $rpm_List ',')
	#调用函数，判断rpm包是否安装
	for i in ${rpm_Lists[@]}
    	do
        	(func_rpm $i;echo $i:$?>>$local_dir/rpm.log)&
    	done
   	 wait
	fail_num=`cat $local_dir/rpm.log | grep -v ':0'|grep -v " "|wc -l`
	succed_num=`cat $local_dir/rpm.log | grep ':0'|grep -v " "|wc -l`
	failed_rpm_list=`cat $local_dir/rpm.log |grep -v ':0'|cut -d ":" -f 1`
	succed_rpm_list=`cat $local_dir/rpm.log |grep ':0'|cut -d ":" -f 1`
	if [ $fail_num -gt 0 ] && [ $succed_num -gt 0 ]
	then
				echo "this rpm installation is failed!!"
				echo "the failed rpm list is $failed_rpm_list"
				echo "the succed rpm list is $succed_rpm_list"
				exit 1
	elif [ $fail_num -gt 0 ]
	then
				echo "this rpm installation is failed!!"
				echo "the failed rpm list is $failed_rpm_list"
				exit 1
	else
				echo "all of the rpm installation are sucessful!"
				echo "the succed rpm list is $succed_rpm_list"
	fi
elif [ $rpm_IsRequired == 'true' ] && [  "$rpm_List"X == X ]
then
	echo "the rpm variable is not corrected,please check it !!"
else
 	echo "rpm is not required, skip the installation"
fi

