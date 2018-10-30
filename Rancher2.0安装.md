一、操作系统设置(7.2~7.5)
    1.停防火墙:
        a. systemctl stop firewalld.service
        b. systemctl disable firewalld.service
        c. setenforce 0
        d. vim /etc/sysconfig/selinux
             SELINUX=disabled

    2.网络转发参数设置:
        a. echo "1" > /proc/sys/net/ipv4/ip_forward
        b. echo "net.ipv4.ip_forward = 1"  >> /usr/lib/sysctl.d/00-system.conf

二、安装docker环境
    1.安装docker基础环境(缺省1.12.6版本)
        a. yum install docker
        b. systemctl enable docker.service
        c. systemctl start  docker.service
        d. 采用国内镜像库:
            修改/etc/docker/daemon.json 文件并添加上 registry-mirrors 键值:
              {
                  "registry-mirrors": ["https://registry.docker-cn.com"]
              }
            修改保存后重启 Docker服务 以使配置生效。
        e.Rancher2.0启动kubelet报错预防配置:
          a).修改/etc/systemd/system/multi-user.target.wants/docker.service中MountFlags设置，值从slave改为shared
          b).systemctl daemon-reload
          c).systemctl restart docker.service

    2.以前安装过rancher或k8s的主机环境清理
        docker rm -f -v $(docker ps -aq) 
        docker volume rm $(docker volume ls)
        rm -rf /var/lib/etcd/
        rm -rf /etc/kubernetes
        docker rmi $(docker images -q)

三、安装Rancher2.0服务端或客户端:(以v2.0.8版为例)
    1.安装docker-server:
        docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.0.8
        浏览器登录docker-server所在主机IP的80端口,admin/admin

    2.安装docker-agent:
        在docker-server的集群配置界面获取docker-agent安装命令行:
        docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:master --server https://192.168.137.131 --token 9455mjxzwfcscmtvdjjp25hvbjpzkrbjwrg87gnk2ws9qfzlp87jhf --ca-checksum 1d382c6629a720f33abac40caa96bf59262349e3a55bb9390fda8bb5967c5ff1 --etcd --controlplane --worker