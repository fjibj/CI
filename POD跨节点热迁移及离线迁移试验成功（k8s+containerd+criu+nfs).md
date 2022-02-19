（仅是安装过程中的一些记录，未详细整理）
k8s+containerd+podmigration


---------------------------------------
yum安装snap (不需要安装snap）

https://www.linuxidc.com/Linux/2020-03/162485.htm

setenforce 0


设置snap代理：

在/etc/environment中加入：

http_proxy=http://[服务器地址]:[端口号]

https_proxy=http://[服务器地址]:[端口号]

snap set system proxy.http="http://xxxx:yy"

snap set system proxy.https="http://xxxx:yy"


snap install go --classic

/var/lib/snapd/snap/bin/go

---------------------------------------


yum install -y kubelet-1.19.0 kubeadm-1.19.0 kubectl-1.19.0 --disableexcludes=kubernetes

systemctl enable --now kubelet


# 编译k8s : https://github.com/vutuong/kubernetes

yum -y install golang

vim /etc/profile

在文件的末尾添加如下代码：

export GOROOT=/usr/lib/golang

export PATH=$PATH:$GOROOT/bin

#source /etc/profile

#go env

go env -w GO111MODULE=on

go env -w GOPROXY="https://goproxy.cn,direct"



cd kubernetes

make

编译好的放在_output/local/bin下

彻底清除docker：https://www.ydyno.com/archives/1278.html

docker kill $(docker ps -a -q)

docker rm $(docker ps -a -q)

docker rmi $(docker images -q)

systemctl stop docker

rm -rf /etc/docker

rm -rf /run/docker

rm -rf /var/lib/dockershim

rm -rf /var/lib/docker

rm -f /usr/bin/docker*

umount /var/lib/docker/devicemapper

yum list installed | grep docker #查看已安装的docker包

yum remove docker-engine docker-engine-selinux.noarch

# 彻底删除k8s

kubeadm reset -f

yum remove -y kubelet-1.19.0 kubeadm-1.19.0 kubectl-1.19.0

rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/* /etc/systemd/system/kube*


# Kubernetes集群之清除集群
https://o-my-chenjian.com/2017/05/11/Clear-The-Cluster-Of-K8s/


swapoff -a

kubeadm reset

modprobe br_netfilter

echo '1' > /proc/sys/net/ipv4/ip_forward

kubeadm init

systemctl status kubelet

-----------------------------------------------------------------------------------------------------------------------

# CentOS7下 kubernetes containerd版安装 （OK）

https://blog.csdn.net/flywingwu/article/details/113482681

wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.19.0/crictl-v1.19.0-linux-amd64.tar.gz

tar zxvf crictl-v1.19.0-linux-amd64.tar.gz -C /usr/local/bin

containerd设置代理：

#mkdir /etc/systemd/system/containerd.service.d

#vim  /etc/systemd/system/containerd.service.d/http_proxy.conf

 [Service]

Environment="HTTP_PROXY=http://172.32.147.188:9999" "HTTPS_PROXY=http://172.32.147.188:9999" "NO_PROXY=kubefate.net,172.32.150.133,172.32.150.134,172.32.150.135,8.8.8.8,114.114.114.114,127.0.0.1,localhost,172.32.0.0/12,10.96.0.0/12,192.168.0.0/16"

#重启containerd 

$ systemctl daemon-reload 

$ systemctl restart containerd

解决coredns 0/1问题：（清除所有iptables规则，慎用！！！）

iptables -P INPUT ACCEPT

iptables -P FORWARD ACCEPT

iptables -P OUTPUT ACCEPT

iptables -F

$ vim /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf 

#加入下面内容

Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"

yum install -y kubelet-1.19.0 kubeadm-1.19.0 kubectl-1.19.0

systemctl enable kubelet.service

如果加入集群的指令找不到了，可以使用下面命令重新获得：

kubeadm token create --print-join-command

登录到node节点，确保已经安装了docker和kubeadm，kubelet，kubectl，执行：

kubeadm join 172.32.150.133:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:841686098dd5c2a34e7f1e872d6daab969853ba11566190b7d845fadb9ccc02c 

kubeadm join 172.32.150.133:6443 --token wp9k1h.lvoy8darcdmwk98b     --discovery-token-ca-cert-hash sha256:841686098dd5c2a34e7f1e872d6daab969853ba11566190b7d845fadb9ccc02c

mkdir ~/.kube

vim ~/.kube/config

and copy the config file from mster node to nodes config file


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 安装特定contaierd

参考 https://github.com/SSU-DCN/podmigration-operator/blob/main/init-cluster-containerd-CRIU.md

step1 和 step2

containerd config default > /etc/containerd/config.toml

修改config.toml

sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.2"

[plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = "io.containerd.runtime.v1.linux"
        runtime_engine = "/usr/local/bin/runc"
        runtime_root = ""


systemctl daemon-reload

systemctl restart containerd

systemctl status containerd

systemctl daemon-reload

systemctl restart kubelet

systemctl status kubelet

journalctl -xfu kubelet

# 强制删除pod（慎用）

kubectl delete pod xxx --force --grace-period=0

在所有node上

$ git clone https://github.com/SSU-DCN/podmigration-operator.git

$ cd podmigration-operator

$ tar -vxf binaries.tar.bz2

$ cd custom-binaries

$ chmod +x kubeadm kubelet

先备份/usr/bin/kubeadm和kubelet

$ sudo mv kubeadm kubelet /usr/bin/

git clone https://github.com/vutuong/kubernetes.git

将kubernetes目录与podmigration-operator放在同一层

# 安装NFS共享目录

https://cloud.tencent.com/developer/article/1721166

·	Config NFS server at Master node

mkdir -p /var/lib/kubelet/migration/

chmod 777 /var/lib/kubelet/migration

yum -y install rpcbind nfs-utils

vim /etc/exports

/var/lib/kubelet/migration/  172.32.150.134(rw,sync,no_subtree_check) 172.32.150.135(rw,sync,no_subtree_check)

exportfs -r
    
防火墙配置（暂略）

systemctl start rpcbind

systemctl start nfs

systemctl enable rpcbind

systemctl enable nfs


·	Config NFS client at every worker nodes

yum -y install rpcbind

mkdir -p /var/lib/kubelet/migration/

chmod 777 /var/lib/kubelet/migration

mount -t nfs 172.32.150.133:/var/lib/kubelet/migration/ /var/lib/kubelet/migration/ -o nolock,nfsvers=3,vers=3

vim /etc/rc.d/rc.local

#在文件最后添加一行：

mount -t nfs 172.32.150.133:/var/lib/kubelet/migration/ /var/lib/kubelet/migration/ -o nolock,nfsvers=3,vers=3

df -h

# podmigration-operator

·	To run Podmigration operator, which includes CRD and a custom controller:

$ git clone https://github.com/SSU-DCN/podmigration-operator.git

$ cd podmigration-operator

go install sigs.k8s.io/kustomize/v3/cmd/kustomize@latest

make manifests

--------------------

·	To run api-server, which enables kubectl migrate command and GUI:

$ go run ./api-server/cmd/main.go

------------------------------

·	To install kubectl migrate/checkpoint command, follow the guide at https://github.com/SSU-DCN/podmigration-operator/tree/main/kubectl-plugin

cd podmigration-operator/kubectl-plugin/

·	To run GUI:

先升级gcc

yum -y install centos-release-scl

yum -y install devtoolset-7-gcc*

scl enable devtoolset-7 bash

which gcc

gcc --version

curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -

yum install nodejs -y

$ cd podmigration-operator/gui

$ export CXXFLAGS="--std=c++17" && npm install

$ npm run serve
 

# 安装CRIU

！！必须自己编译安装

https://criu.org/Installation

#criu check --all


# 跑个例子：

cd podmigration-operator/config/samples/migration-example

vim 1.yaml 

……

nodeSelector:

    	kubernetes.io/hostname: k8s-node02

kubectl apply -f 1.yaml

kubectl get pods -o wide


修改：

vim /mnt/disk01/fangjin/projects/containerd/podmigration-operator/kubectl-plugin/checkpoint-command/checkpoint_command.go

//config, _ := clientcmd.BuildConfigFromFlags("", "/home/dcn/fault-detection/docs/anisble-playbook/kubernetes-the-hard-way/admin.kubeconfig")

config, _ := clientcmd.BuildConfigFromFlags("", "/root/.kube/config")

# kubectl checkpoint simple /var/lib/kubelet/migration/simple

$ cd checkpoint-command

$ go build -o kubectl-checkpoint

$ cp kubectl-checkpoint /usr/local/bin




vim test1.yaml

……

destHost: k8s-node01

kubectl apply -f test1.yaml


curl --request POST 'localhost:5000/Podmigrations' --header 'Content-Type: application/json' --data '{"name":"test1", "replicas":1, "action":"live-migration", "sourcePod":"simple", "destHost":"k8s-node01"}'



curl --request GET 'localhost:5000/Podmigrations'

成功！

[root@k8s-master01 ~]# kubectl get pod -o wide

NAME                  READY   STATUS        RESTARTS   AGE     IP             NODE         NOMINATED NODE   READINESS GATES

simple                1/1     Terminating   0          21h     10.244.1.6     k8s-node02   <none>           <none>
  
simple-migration-29   1/1     Running       0          8m27s   10.244.2.111   k8s-node01   <none>           <none>
  
[root@k8s-master01 ~]# kubectl logs pod/simple
  
Error from server (NotFound): pods "simple" not found
  
[root@k8s-master01 ~]# kubectl logs pod/simple-migration-29
  
76077
  
76078
  
76079
  
76080
  
76081

 
# 离线迁移

checkpoint的恢复：
 
you can use the sample template in https://github.com/SSU-DCN/podmigration-operator/blob/main/config/samples/podmig_v1_restore.yaml to create start applications from checkpoint image with the path of checkpoint data, called snapshotPath, defined inside.

# cat restore_t1.yaml 
 
apiVersion: podmig.dcn.ssu.ac.kr/v1
 
kind: Podmigration
 
metadata:
 
  name: test
 
  labels:
 
    name: test
 
spec:
 
  replicas: 1
 
  action: restore
 
  snapshotPath: /var/lib/kubelet/migration/kkk/simple
 
  destHost: k8s-node01
 
  selector:
 
    podmig: dcn
 
  # When restore a number of pods from existing checkpoint infomation, a pre-template should be defined to pre-create a new pod first, then the checkpoint info will be loaded
 
  template:
 
    metadata:
 
      name: simple
 
      labels:
 
        name: simple
 
    spec:
 
      containers:
 
      - name: count
 
        image: alpine
 
        ports:
 
        - containerPort: 80
 
          protocol: TCP

[root@k8s-master01 samples]# kubectl apply -f restore_t1.yaml 
 
podmigration.podmig.dcn.ssu.ac.kr/test created
 
[root@k8s-master01 samples]# kubectl get pod -o wide
 
NAME                    READY   STATUS    RESTARTS   AGE   IP             NODE         NOMINATED NODE   READINESS GATES
 
simple-migration-0      1/1     Running   0          63m   10.244.1.9     k8s-node02   <none>           <none>
 
simple2-migration-42    1/1     Running   0          74m   10.244.2.114   k8s-node01   <none>           <none>
 
test-79b887d8dd-dcvx7   1/1     Running   0          20s   10.244.2.115   k8s-node01   <none>           <none>
 

[root@k8s-master01 samples]# kubectl logs -f pod/test-79b887d8dd-dcvx7
 
86240
 
86241
 
86242
 
86243
 
86244
 
# very good!
 

  
# 获得迁移：
  
kubectl get podmigrations


checkpoint之后删除pod失败：（貌似不行）
  
echo 1 > /proc/sys/fs/may_detach_mounts
  
或者
  
sysctl -w fs.may_detach_mounts=1
