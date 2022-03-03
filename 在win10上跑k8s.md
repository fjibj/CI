#  在win10上跑k8s

参考: https://blog.miniasp.com/post/2021/12/05/Running-Kubernetes-with-MicroK8s
-------------------------------
离线安装Chocolatey （可选）
下载：https://community.chocolatey.org/api/v2/package/chocolatey/0.12.1
       set-ExecutionPolicy RemoteSigned
       iex F:\tools\setup.ps1

       PS C:\Users\Administrator> choco
Chocolatey v0.12.1
Please run 'choco -?' or 'choco <command> -?' for help menu.

————————————————————————


下载helm: https://get.helm.sh/helm-v3.8.0-windows-amd64.zip
解压并把路径加到PATH环境变量中
   
```
microk8s install

multipass shell microk8s-vm

----
sudo snap install docker

sudo docker pull mirrorgooglecontainers/pause:3.1
sudo docker tag mirrorgooglecontainers/pause:3.1 k8s.gcr.io/pause:3.1
sudo docker save k8s.gcr.io/pause > pause.tar
sudo microk8s.ctr image import pause.tar

exit
-----
microk8s stop
microk8s start


microk8s status --wait-ready

microk8s kubectl get nodes

microk8s config > ~/.kube/config


kubectl describe node/microk8s-vm

microk8s enable dns
microk8s enable helm3

microk8s enable storage
microk8s enable dashboard


sudo snap install docker
----
sudo docker pull cnskylee/metrics-server:v0.5.0
sudo docker tag cnskylee/metrics-server:v0.5.0 k8s.gcr.io/metrics-server/metrics-server:v0.5.0
sudo docker save k8s.gcr.io/metrics-server/metrics-server > metrics-server.tar
sudo microk8s.ctr image import metrics-server.tar

----
microk8s dashboard-proxy
在浏览器打开dashboard，输入token

查看资源使用情况：
kubectl top node
kubectl top pod --all-namespaces

microk8s enable prometheus
microk8s kubectl port-forward -n monitoring service/grafana --address 0.0.0.0 3000:3000  #开启Grafana 的Web UI ( http://localhost:3000 ) (预设登入帐号密码为admin/ admin)
microk8s kubectl port-forward -n monitoring service/prometheus-k8s --address 0.0.0.0 9090:9090 #开启Prometheus 的Web UI ( http://localhost:9090 )

kubectl get all -o wide --all-namespaces

```

# 缺包统一采用上面进入microk8s-vm，sudo docker search, tag, save, import的方式处理
参考：win10 下 microk8s安装记录
https://blog.csdn.net/weixin_46359306/article/details/119546083




通过snap方式安装docker，daemon.json文件的位置
/var/snap/docker/current/config

重启docker：
sudo snap restart docker

参考：ubuntu 20.04 以 snap 的方式 安装docker 使用zfs文件系统  https://www.cnblogs.com/jijizhazha/p/13170711.html


# Multipass常用命令
```
multipass launch --name microk8s-vm --mem 4G --disk 40G
multipass list

multipass shell microk8s-vm

Then install the MicroK8s snap and configure the network:
sudo snap install microk8s --classic --channel=1.18/stable
sudo iptables -P FORWARD ACCEPT

multipass shell microk8s-vm

multipass stop microk8s-vm

multipass delete microk8s-vm
multipass purge
```
