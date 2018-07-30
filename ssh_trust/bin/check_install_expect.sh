#!/bin/bash

yum_path=/etc/yum.repos.d

shell_path=`dirname $0`
cd $shell_path
bin_path=`pwd`
conf_path=$bin_path/../conf
soft_path=$bin_path/../soft
log_path=$bin_path/../log

echo "===check whether yum's backup folder exists or not==="
if [ -d $yum_path/backup ];then
  echo "==> backup folder exists,do nothing"
else
  mkdir $yum_path/backup
  echo "==> backup make success,and move * to backup"
fi

mv $yum_path/* $yum_path/backup

echo "=== start configuring yum's local.repo now ==="

rh_cs_os_version=`cat /etc/redhat-release | awk '{print $(NF -1)}'`

if [ $rh_cs_os_version == 7.4.1708 ];then
      echo   > $yum_path/local.repo
      echo "[base]" >> $yum_path/local.repo
      echo "name=CentOS-$releasever - Base" >>  $yum_path/local.repo
      echo "baseurl=http://10.45.59.200:20000/" >>  $yum_path/local.repo 
      echo "enabled=1" >>  $yum_path/local.repo
      echo "gpgcheck=0"  >>  $yum_path/local.repo

   elif [ $rh_cs_os_version == 6.6 ];then
      echo   > $yum_path/local.repo
      echo "[yum6.6]" >> $yum_path/local.repo
      echo "name=yum6.6" >>  $yum_path/local.repo
      echo "baseurl=http://10.45.59.200:26666/" >>  $yum_path/local.repo
      echo "enabled=1" >>  $yum_path/local.repo
      echo "gpgcheck=0"  >>  $yum_path/local.repo

   elif [ $rh_cs_os_version == 6.5 ];then
      echo   > $yum_path/local.repo
      echo "[yum6.5]" >> $yum_path/local.repo
      echo "name=yum6.6" >>  $yum_path/local.repo
      echo "baseurl=http://10.45.59.200:25555/" >>  $yum_path/local.repo
      echo "enabled=1" >>  $yum_path/local.repo
      echo "gpgcheck=0"  >>  $yum_path/local.repo

   else
     echo "error"
    
fi

yum install -y expect

which expect > /dev/null 2>&1
if [ $? != 0 ];then
  echo -e "=========================="
  echo -e "expect install failed"
  echo -e "=========================="
 else
  echo -e "==> expect install success"
fi
