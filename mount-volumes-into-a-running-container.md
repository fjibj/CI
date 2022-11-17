将卷挂载到正在运行的容器中（通过！）

参考：

https://medium.com/kokster/mount-volumes-into-a-running-container-65a967bee3b5

https://jpetazzo.github.io/2015/01/13/docker-mount-dynamic-volumes/

把主机上的/home/test 目录挂载到容器的/doot

主机上：

[root@vcapp133 ~]# df /home/test
Filesystem              1K-blocks     Used Available Use% Mounted on
/dev/mapper/centos-root 104806400 86212556  18593844  83% /

[root@vcapp133 test]# less /proc/self/mountinfo

……
68 1 253:0 / / rw,relatime shared:1 - xfs /dev/mapper/centos-root rw,attr2,inode64,logbufs=8,logbsize=32k,noquota
……

[root@vcapp133 ~]# docker run -dt --name ddd -p 44000:3389 -p 44002:22 --hostname master XXXXX:20220628

[root@vcapp133 ~]# docker exec -it ddd /bin/bash

容器内：

[root@master tmp]# mkdir /dev/mapper

[root@master tmp]# [ -b /dev/mapper/centos-root ] || mknod --mode 0600 /dev/mapper/centos-root b 253 0

[root@master mapper]# mkdir -p /tmpmount

[root@master mapper]# mount /dev/mapper/centos-root /tmpmount
mount: permission denied

主机上：

[root@vcapp133 test]# docker inspect --format {{.State.Pid}} 7f704818e3cb
22486

[root@vcapp133 test]# nsenter --target 22486 --mount --uts --ipc --net --pid -- mount /dev/mapper/centos-root /tmpmount

容器内：

[root@master mapper]# ls /tmpmount

bin   data  etc   lib    media  opt   root  sbin   snap  sys  usr
boot  dev   home  lib64  mnt    proc  run   share  srv   tmp  var

[root@master /]# mkdir /doot

[root@master /]# mount -o bind /tmpmount/home/test /doot
mount: permission denied

主机上：

[root@vcapp133 test]# nsenter --target 22486 --mount --uts --ipc --net --pid -- mount -o bind /tmpmount/home/test /doot

容器内：

[root@master tmpmount]# ll /doot/

total 4204
-rwxr-xr-x 1 root root 4302416 Apr  1  2021 cloaker_cli_linux

主机上：
[root@vcapp133 test]# nsenter --target 22486 --mount --uts --ipc --net --pid -- umount /tmpmount

[root@vcapp133 test]# nsenter --target 22486 --mount --uts --ipc --net --pid -- rmdir /tmpmount


容器内：

[root@master /]# ll doot/

total 4204
-rwxr-xr-x 1 root root 4302416 Apr  1  2021 cloaker_cli_linux

---------------------------

LCXFS情况下是否仍可动态挂载？

[root@vcapp133 lxcfs-lxcfs-5.0.2]# /usr/bin/lxcfs --version
"5.0.2"

[root@vcapp133 lxcfs-lxcfs-5.0.2]# /usr/bin/lxcfs --enable-cfs -l /var/lib/lxc/lxcfs/
……


[root@vcapp133 ~]# docker run -dt -m 5g --cpu-period=10000 --cpu-quota=20000 \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro  \
-v /var/lib/lxc/:/var/lib/lxc/:shared \
-v /var/lib/lxc/lxcfs/proc/diskstats:/proc/diskstats:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/meminfo:/proc/meminfo:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/stat:/proc/stat:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/swaps:/proc/swaps:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/uptime:/proc/uptime:rw,rslave \
-v /var/lib/lxc/lxcfs/proc/loadavg:/proc/loadavg:rw,rslave \
-v /var/lib/lxc/lxcfs/sys/devices/system/cpu/online:/sys/devices/system/cpu/online:ro \
--name ddd -p 44000:3389 -p 44002:22 --hostname master \
XXXXX:20220628

主机上：
[root@vcapp133 ~]# docker inspect --format {{.State.Pid}} 4f42dc3ae70b
27243

[root@vcapp133 ~]# nsenter --target 27243 --mount --uts --ipc --net --pid -- \
> mount /dev/mapper/centos-root /tmpmount
mount: special device /dev/mapper/centos-root does not exist （失败）

但可以把要挂的目录放到宿主机/var/lib/lxc/下（不要放到/var/lib/lxc/lxcfs下）

注： 将lxcfs目录完全挂载到容器中会造成较大风险，参考 https://www.ai2news.com/blog/1441724/

---------------------------

