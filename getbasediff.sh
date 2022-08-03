#!/bin/bash

SOURCEIMG=$1
SOURCETAG=$2
TARGETIMG=$3
TARGETTAG=$4

OVERLAYDIR=/var/lib/docker/overlay2

#安装jq
#yum install -y jq

#拉取镜像到本地
#docker pull $SOURCEIMG:$SOURCETAG
#docker pull $TARGETIMG:$TARGETTAG

#找源基础镜像的最上层目录UpperDir
UpperDir=`docker inspect $SOURCEIMG:$SOURCETAG |jq .[0].GraphDriver.Data.UpperDir |sed 's/\"//g'`

#找目标镜像中在源镜像UpperDir之上的目录/diff（如果没有取目标镜像所有目录/diff）按顺序由低到高排序
declare -a arr1
SS=`docker inspect $TARGETIMG:$TARGETTAG |jq .[0].GraphDriver.Data.LowerDir |sed 's/\"//g'`
arr=(${SS//:/ })
len=${#arr[*]}
find=0
j=0
for ((i=len-1;i>=0;i--))
do
   if [ $find -eq 0 ];then
	    if [ ${arr[i]} = $UpperDir ];then
         find=1
       fi
   else
       arr1[$j]=${arr[i]}
       ((j++))
   fi
done
if [ $find -eq 0 ];then
	j=0
	for ((i=len-1;i>=0;i--))
   do
       arr1[$j]=${arr[i]}
       ((j++))
   done 
fi
newupperdir=`docker inspect $TARGETIMG:$TARGETTAG |jq .[0].GraphDriver.Data.UpperDir |sed 's/\"//g'`
arr1[$j]=$newupperdir

#将上述中所有目录内容依次写入“overlay2/tmp/base-目标镜像版本号”中，逐层覆盖
TMPDIR=$OVERLAYDIR/tmp/BASE-$TARGETTAG/diff
mkdir -p $TMPDIR
len1=${#arr1[*]}
for ((i=len1-1;i>=0;i--))
do
    \cp -af ${arr1[i]}/* $TMPDIR/ >> $TMPDIR/../log.log
done

#将/tmp/BASE-$TARGETTAG/diff下的内容打包
cd $TMPDIR/..
tar -cvzf BASE-$TARGETTAG-diff.tar.gz ./diff

