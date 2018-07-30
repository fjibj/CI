#!/bin/bash

shell_path=`dirname $0`
cd $shell_path
bin_path=`pwd`
conf_path=$bin_path/../conf
soft_path=$bin_path/../soft
log_path=$bin_path/../log
cd $bin_path/..

mkdir -p  ~/.pip
cat <<EOF > ~/.pip/pip.conf
[global]
index-url = http://10.45.59.184:8888/simple/

[install]
trusted-host=10.45.59.184
EOF


yum install -y gcc smartmontools dmidecode python-pip python-devel  libselinux-python


cd $soft_path

tar xvzf pip-9.0.1.tar.gz
tar xvzf setuptools-2.0.tar.gz

cd setuptools-2.0

python setup.py build && python setup.py install

cd ../pip-9.0.1

echo ======pip.sh==========
echo $soft_path/pip-9.0.1
echo ======pip.sh==========


python setup.py install > /tmp/pip_setup.log


echo ======pip.sh=================================================
echo $bin_path/adminset_agent.py
echo ======pip.sh================================================

nohup python $bin_path/adminset_agent.py >/tmp/adminset.log &
