#! /bin/bash

PATH=$PATH:/bin
LXCFS="/var/lib/lxc/lxcfs"
LXCFS_ROOT_PATH="/var/lib/lxc"

containers=$(docker ps | grep -v pause  | grep -v calico | awk '{print $1}' | grep -v CONTAINE)

#-v /var/lib/lxc/lxcfs/proc/cpuinfo:/proc/cpuinfo:rw
#-v /var/lib/lxc/lxcfs/proc/diskstats:/proc/diskstats:rw
#-v /var/lib/lxc/lxcfs/proc/meminfo:/proc/meminfo:rw
#-v /var/lib/lxc/lxcfs/proc/stat:/proc/stat:rw
#-v /var/lib/lxc/lxcfs/proc/swaps:/proc/swaps:rw
#-v /var/lib/lxc/lxcfs/proc/uptime:/proc/uptime:rw
#-v /var/lib/lxc/lxcfs/proc/loadavg:/proc/loadavg:rw
#-v /var/lib/lxc/lxcfs/sys/devices/system/cpu/online:/sys/devices/system/cpu/online:rw
for container in $containers;do
	mountpoint=$(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/lib/lxc" }}{{ .Source }}{{ end }}{{ end }}' $container)
	if [ "$mountpoint" = "$LXCFS_ROOT_PATH" ];then
		echo "remount $container"
		PID=$(docker inspect --format '{{.State.Pid}}' $container)
		# mount /proc
		for file in meminfo cpuinfo loadavg stat diskstats swaps uptime;do
			echo nsenter --target $PID --mount --  mount -B "$LXCFS/proc/$file" "/proc/$file"
			nsenter --target $PID --mount --  mount -B "$LXCFS/proc/$file" "/proc/$file"
		done
		# mount /sys
		for file in online;do
			echo nsenter --target $PID --mount --  mount -B "$LXCFS/sys/devices/system/cpu/$file" "/sys/devices/system/cpu/$file"
			nsenter --target $PID --mount --  mount -B "$LXCFS/sys/devices/system/cpu/$file" "/sys/devices/system/cpu/$file"
		done 
	fi 
done
