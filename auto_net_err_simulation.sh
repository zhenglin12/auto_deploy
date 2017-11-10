#!/bin/bash

# parse the paramters
# -H=net_err_host -T=net_err_target -I=net_err_interval -S=delay_time_ms -J=delay_time_interval -G=operate_interval
echo 'shell paramters is as follows'
echo $#
echo "##############check the paramters############"
for i in "$@"
do
        para=$i
        echo $para

        case $para in
                -H*)
                                                net_err_host=`echo $para |cut -d'='  -f 2`
                        ;;

                -T*)
                                                net_err_target=`echo $para |cut -d'='  -f 2`
                                                ;;
                -I*)
                                                net_err_interval=`echo $para |cut -d'='  -f 2`
                        ;;

                -S*)
                                                delay_time_ms=`echo $para |cut -d'='  -f 2`

                        ;;
                -J*)
                                                delay_time_interval=`echo $para |cut -d'='  -f 2`

                        ;;


                -G*)
                                                operate_interval=`echo $para |cut -d'='  -f 2`
                                                if [ "$operate_interval"x == x ]
                                                then
                                                    operate_interval=30
                                                fi
                        ;;
        esac
done

#splite the ip:port into ip and port
#####function for splite server_list#############
func_splite(){

num=`echo $1|awk -F$2 '{print NF-1}'`
if [ ${num} == 0 ]
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
                                                #       echo "$split"
                                                         server[i-2]="$split"
                else
                        break
                fi
        done

fi
echo "${server[@]}"
}

#splite the ip:ports into the ip:port
if [ "$net_err_host"x != x ]
then
    ip_ports=$(func_splite $net_err_host ',')
    echo ${ip_ports}
    for ip_port in ${ip_ports[@]}
    do

            list=$(func_splite $ip_port ':')
            ip=`echo "$list"|cut -d ' ' -f1`

            port=`echo "$list"|cut -d ' ' -f2`

            echo "the all parameter has been parsed!!"
            if [ "$ip" == "*" ] && [ "$port" != "*" ]
            then
		echo "begin to interrupt the network for port $port with any ip"

                iptables -A INPUT -p tcp --dport ${port} -j ${net_err_target}
                iptables -A OUTPUT -p tcp --sport ${port} -j ${net_err_target}
                sleep ${net_err_interval}
                iptables -F
		echo "the network has been recovered!!"

            elif [ "$port" == "*" ] && [ "$ip" != "*" ]
            then
		echo "begin to interrupt the network for ip $ip with any port"

                iptables -A INPUT -s ${ip} -p tcp -j ${net_err_target}
                iptables -A OUTPUT -d ${ip} -p tcp -j ${net_err_target}
                sleep ${net_err_interval}
                iptables -F
		echo "the network has been recovered!!"
            elif [ "$port" != "*" ] && [ "$ip" != "*" ]
            then
                echo "begin to interrupt the network on port $port with ip $ip"
                iptables -A INPUT -s ${ip} -p tcp --dport ${port} -j ${net_err_target}
                iptables -A OUTPUT -d ${ip} -p tcp --sport ${port} -j ${net_err_target}
                sleep ${net_err_interval}
                iptables -F
		echo "the network has been recovered!!"
            fi
    done
    if [ "${operate_interval}X" != "X" ]
    then
    	sleep ${operate_interval}m
    fi
fi

#fetch the etho name
if [ "delay_time_ms"x != x ]
then
    ifconfig|cut -d ' ' -f 1 >ip.text
    band=`sed -n '1,1p' ip.text`
    echo "begin to delay all the package on the machine"
    tc  qdisc  add  dev  ${band}  root  netem  delay  ${net_delay}ms
    sleep ${delay_time_interval}
    tc  qdisc  del  dev  ${band}  root
    echo "the net has been recovered!!"
fi
