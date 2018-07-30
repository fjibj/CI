#!/bin/bash

shell_path=`dirname $0`
cd $shell_path
bin_path=`pwd`
conf_path=$bin_path/../conf
soft_path=$bin_path/../soft
log_path=$bin_path/../log
cd $bin_path/..
file_path=`pwd`
my_ip=`/sbin/ifconfig -a|grep inet|grep 10.45|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
remote_dir=/shell
my_user=`whoami`
my_home=`cat /etc/passwd | grep root | awk -F: '{print $6}'|head -1`
my_root_passwd=ztesoft123


. $bin_path/functions.sh

echo -e "\n"
echo -e "####################################################################################"
echo -e "ip:$my_ip"
echo -e "user:$my_user"
echo -e "\n"


if [  -f $my_home/.ssh/id_rsa.pub ];then
    echo -e "==> id_rsa.pub exists,do noting"
 else
    echo -e "==> id_rsa.pub doesn't exist ,create it"
    $bin_path/create_rsa.sh
    echo -e "\n"
    echo -e "====================="
    echo -e "my id create complete"
    echo -e "=====================\n"
fi

echo -e "==> start copying id"
while read LINE
 do
   ip=`echo $LINE|awk '{print $1}'`
   user=`echo $LINE | awk '{print $2}'`
   password=`echo $LINE | awk '{print $3}'`

   ssh_copy_id $user $ip $password

   echo -e "============================================================================"
   echo -e "[$my_ip--$my_user's id_rsa.pub] copying id to [$ip'$user] complete"
   echo -e "============================================================================\n"

 done < $conf_path/ip_user_pwd_root
