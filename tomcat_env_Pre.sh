#先清理环境，一旦出现异常，则退出
set -x
ssh_Username=$1
dst_dir=$2
java_version=$3
java_path=$4
tomcat_path=$5
file_path=$6
tomcat_version=$7
if [ "$ssh_Username"X == X ] || [ "$dst_dir"X == X ] || [ "$java_version"X == X  ]
then 
	echo "the variable is not exitsted!!"
	exit 2
fi
#mkdir -p $dst_dir

#安装环境,一旦出现异常，则退出
#检查环境是否安装，如果安装，则跳过安装
#判断java 是否安装
source /etc/profile
java -version >java.txt 2>&1
if [ $? -ne 0  ]
then 
        echo "java is not installed!!"
fi
chmod 777 java.txt
local_dir=`pwd`
if_Jdk=`cat $local_dir/java.txt|grep 'Java(TM) SE Runtime Environment'` 
if_version=`cat $local_dir/java.txt|grep  $java_version`

if [ "$if_Jdk"X != X ]&& [ "$if_version"X != X ]
then 
        echo "the required is  is installed !!"
elif [ "$if_Jdk"X != X ]
then
		echo "###install the jdk $java_version automtically in the $java_path####"
		set -e
		#to determine the path
		 cd $java_path 
		 rm -rf jdk$java_version
		wget --help >wget.txt 2>&1
		if_installed=`cat wget.txt|grep "--version"`

		if [ "$if_installed"X == X ]
		then 
			 echo "the wget is not installed!!"
			echo "#####install the wget !!#####"
		          yum install -y wget >/dev/null 2>&1
			
		fi
		echo "######begin to install the java ##########"
		 wget http://10.9.0.149/jdk$java_version.tar.gz >/dev/null 2>&1
		 tar -xzf  jdk$java_version.tar.gz
		 rm -rf jdk$java_version.tar.gz
		 mv jdk$java_version* jdk$java_version
		
		#symbolic link
		 rm -rf $java_path/default
		 ln -s $java_path/jdk$java_version $java_path/default
		 echo "revise the /etc/profile !!"		
		 sed -i '/JAVA_HOME/d' $file_path
		 sed -i '/JRE_HOME/d' $file_path
		 sed -i '$a export JAVA_HOME='$java_path'/default' $file_path
		 sed -i '$a export JRE_HOME='$java_path'/default/jre' $file_path
		 sed -i '$a export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH' $file_path
		 sed -i '$a export PATH=$JAVA_HOME/bin:$PATH' $file_path
		 source $file_path
		 set +e
			
		#修改/etc/profile文件
else
		set -e
		echo "###install the jdk $java_version automtically in the $java_path####"
		#to determine the path
		 cd $java_path
		rm -rf jdk$java_version
		 wget --help >wget.txt 2>&1
                if_installed=`cat wget.txt|grep "--version"`

                if [ "$if_installed"X == X ]
                then
                         echo "the wget is not installed, begin to install the wget!!"
                         yum install -y wget >/dev/null 2>&1
                fi
		 echo "######begin to install the java ##########"
                 wget http://10.9.0.149/jdk$java_version.tar.gz >/dev/null 2>&1
                 tar -xzf  jdk$java_version.tar.gz
                 rm -rf jdk$java_version.tar.gz
                 mv jdk$java_version* jdk$java_version
		 rm -rf $java_path/default
	         ln -s $java_path/jdk$java_version $java_path/default
		 echo "revise the JAVA_HOME in /etc/profile"
		 sed -i '/JAVA_HOME/d' $file_path
		 sed -i '/JRE_HOME/d' $file_path
		 sed -i '$a export JAVA_HOME='$java_path'/default' $file_path
		 sed -i '$a export JRE_HOME='$java_path'/default/jre' $file_path
		 sed -i '$a export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$CLASSPATH' $file_path
		 sed -i '$a export PATH=$JAVA_HOME/bin:$PATH' $file_path
		 source $file_path		
		set +e
fi		
#tomcat install
mkdir -p $tomcat_path
cd $tomcat_path
if [ -e $tomcat_path/webapps/ROOT ] && [ -e $tomcat_path/conf/server.xml ]
then
	echo "the tomcat has been installed!!"
else 
	 echo "begin to install the tomcat in $tomcat_path"
	 wget http://10.9.0.149/tomcat$tomcat_version.tar.gz
	 tar -xzf tomcat$tomcat_version.tar.gz 
	 cp  -r *tomcat*/* .
	 rm -rf tomcat$tomcat_version.tar.gz
	 rm -rf *tomcat*
	 rm -rf $tomcat_path/webapps/ROOT/*

fi
set +x
