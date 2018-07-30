#!/bin/bash

shell_path=`dirname $0`
cd $shell_path
bin_path=`pwd`
conf_path=$bin_path/../conf
soft_path=$bin_path/../soft
log_path=$bin_path/../log
cd $bin_path/..
file_path=`pwd`
remote_dir=/shell
remote_bin=$remote_dir$bin_path


. $bin_path/functions.sh


while read LINE
 do
   ip=`echo $LINE|awk '{print $1}'`
   user=`echo $LINE | awk '{print $2}'`
   password=`echo $LINE | awk '{print $3}'`

   ssh -n $user@$ip "$remote_bin/pip.sh"
   
   
 done < $conf_path/ip_user_pwd_root

