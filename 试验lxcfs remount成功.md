试验lxcfs remount成功！（原创）


1. 打开一个终端（称为终端1）：
手工编译lxcfs，参考 https://github.com/lxc/lxcfs
git clone git://github.com/lxc/lxcfs
cd lxcfs
meson setup -Dinit-script=systemd --prefix=/usr build/
meson compile -C build/
sudo meson install -C build/

创建目录
[root@vcapp133 lxcfs]#mkdir -p /var/lib/lxc/lxcfs/

启动lxcfs
[root@vcapp133 lxcfs]# /usr/bin/lxcfs -l /var/lib/lxc/lxcfs/
Running constructor lxcfs_init to reload liblxcfs
mount namespace: 4
hierarchies:
  0: fd:   5: name=systemd
  1: fd:   6: cpu,cpuacct
  2: fd:   7: net_cls,net_prio
  3: fd:   8: cpuset
  4: fd:   9: freezer
  5: fd:  10: rdma
  6: fd:  11: pids
  7: fd:  12: memory
  8: fd:  13: blkio
  9: fd:  14: perf_event
 10: fd:  15: devices
 11: fd:  16: hugetlb
Kernel supports pidfds
Kernel supports swap accounting
api_extensions:
- cgroups
- sys_cpu_online
- proc_cpuinfo
- proc_diskstats
- proc_loadavg
- proc_meminfo
- proc_stat
- proc_swaps
- proc_uptime
- proc_slabinfo
- shared_pidns
- cpuview_daemon
- loadavg_daemon
- pidfds


2. 打开另一个终端（称为终端2），启动容器：
[root@vcapp133 projects]# docker run -dt -m 5g \
> -v /sys/fs/cgroup:/sys/fs/cgroup:ro  \
> -v /var/lib/lxc/:/var/lib/lxc/:shared \
> -v /var/lib/lxc/lxcfs/proc/diskstats:/proc/diskstats:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/meminfo:/proc/meminfo:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/stat:/proc/stat:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/swaps:/proc/swaps:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/uptime:/proc/uptime:rw,rslave \
> -v /var/lib/lxc/lxcfs/proc/loadavg:/proc/loadavg:rw,rslave \
> -v /var/lib/lxc/lxcfs/sys/devices/system/cpu/online:/sys/devices/system/cpu/online:rw,rslave \
> --name ddd -p 44000:3389 -p 44002:22 --hostname master \
> 镜像名

aca59d01361d4eba87b4a8152ecb2ccfd9e75c491de07a79b3829a6b756febee
[root@vcapp133 projects]# 

进入容器：
[root@vcapp133 projects]# docker exec -it aca59d01361d /bin/bash
[root@master /]# free
              total        used        free      shared  buff/cache   available
Mem:        5242880       12516     5222180           0        8184     5230364
Swap:             0           0           0
[root@master /]# 

3. 在终端1用Ctrl+C停止lxcfs
^CRunning destructor lxcfs_exit
[root@vcapp133 lxc]# 

4. 在终端2容器内再次执行free
[root@master /]# free
Error: /proc must be mounted
  To mount /proc at boot you need an /etc/fstab line like:
      proc   /proc   proc    defaults
  In the meantime, run "mount proc /proc -t proc"
[root@master /]# 
[root@master /]# 

5. 在终端1再次启动lxcfs
[root@vcapp133 lxc]# /usr/bin/lxcfs -l /var/lib/lxc/lxcfs/
Running constructor lxcfs_init to reload liblxcfs
mount namespace: 4
hierarchies:
  0: fd:   5: name=systemd
  1: fd:   6: cpu,cpuacct
  2: fd:   7: net_cls,net_prio
  3: fd:   8: cpuset
  4: fd:   9: freezer
  5: fd:  10: rdma
  6: fd:  11: pids
  7: fd:  12: memory
  8: fd:  13: blkio
  9: fd:  14: perf_event
 10: fd:  15: devices
 11: fd:  16: hugetlb
Kernel supports pidfds
Kernel supports swap accounting
api_extensions:
- cgroups
- sys_cpu_online
- proc_cpuinfo
- proc_diskstats
- proc_loadavg
- proc_meminfo
- proc_stat
- proc_swaps
- proc_uptime
- proc_slabinfo
- shared_pidns
- cpuview_daemon
- loadavg_daemon
- pidfds

6. 在终端2容器内再次执行free
[root@master /]# free
Error: /proc must be mounted
  To mount /proc at boot you need an /etc/fstab line like:
      proc   /proc   proc    defaults
  In the meantime, run "mount proc /proc -t proc"
[root@master /]# 
[root@master /]# 

7. 再打开一个终端（称为终端3）
查看容器对应的进程PID
参考 https://github.com/xigang/lxcfs-admission-webhook/blob/dev/script/container_remount_lxcfs.sh
[root@vcapp133 lxcfs]# docker ps | grep -v pause  | grep -v calico | awk '{print $1}' | grep -v CONTAINE
aca59d01361d
[root@vcapp133 lxcfs]# docker inspect --format '{{.State.Pid}}' aca59d01361d
6671
重新挂载/proc/meminfo（此处只处理了mem，其他类似）
[root@vcapp133 lxcfs]# nsenter --target 6671 --mount --  mount -B "/var/lib/lxc/lxcfs/proc/meminfo" "/proc/meminfo"
[root@vcapp133 lxcfs]# 

8. 在终端2容器内再次执行free
[root@master /]# free
              total        used        free      shared  buff/cache   available
Mem:        5242880       12440     5222256           0        8184     5230440
Swap:             0           0           0


以下是在k8s上的应用：

1. 更新lxcfs镜像，主要是start.sh，将其中的/var/lib/lxcfs都替换成/var/lib/lxc/lxcfs （参考start.sh)

2. 修改lxcfs-daemonset.yaml，使用更新的lxc镜像，也将挂载部分的/var/lib/lxcfs都替换成/var/lib/lxc/lxcfs （参考lxcfs-daemonset.yaml）

3. 调整应用中Mount部分的配置（参考lesson_test.yaml）

4. 执行container_remount_lxcfs.sh重新挂载lxcfs （参考container_remount_lxcfs.sh）

5. 可以考虑将lxcfs做成本地服务，利用ExecStartPost执行重新挂载（参考lxcfs.service）

6. 可能修改start.sh直接重新挂载更好，待验证

