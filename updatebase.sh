#!/bin/bash

OVERLAYDIR=/mnt/disk01/docker/overlay2

SOURCETAG=$1
TARGETTAG=$2

#安装jq
#yum install -y jq

TMPDIR=$OVERLAYDIR/tmp/BASE-$TARGETTAG/diff
mkdir -p $TMPDIR
cd $TMPDIR/../..

#如果tmp/baseimg.properties文件存在，从中读取基础镜像最上层目录base.dir和原版本号,否则从源基础镜像中获取
if [ -f "baseimg.properties" ]; then
	UpperDir=`grep "base.dir" baseimg.properties | cut -d'=' -f2 | sed 's/\r//'`
	BaseVer=`grep "base.ver" baseimg.properties | cut -d'=' -f2 | sed 's/\r//'`
else
	UpperDir=`docker inspect $SOURCEIMG:$SOURCETAG |jq .[0].GraphDriver.Data.UpperDir |sed 's/\"//g'`
	BaseVer=$SOURCETAG
	echo "base.dir=$UpperDir" > baseimg.properties
	echo "base.ver=$SOURCETAG" >> baseimg.properties
fi

#备份源最上层目录
mkdir -p $TMPDIR/../../backup/$BaseVer
\cp -af $UpperDir/* $TMPDIR/../../backup/$BaseVer/

#解压变更文件包再覆盖基础镜像目录/diff
cd $TMPDIR/../..
tar -xvzf BASE-$TARGETTAG-diff.tar.gz -C $TMPDIR/../
\cp -af $TMPDIR/* $UpperDir/
sed -i "s#^base.ver=.*#base.ver=$TARGETTAG#g" $TMPDIR/../../baseimg.properties

