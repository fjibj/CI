һ������ϵͳ����(7.2~7.5)
    1.ͣ����ǽ:
        a. systemctl stop firewalld.service
        b. systemctl disable firewalld.service
        c. setenforce 0
        d. vim /etc/sysconfig/selinux
             SELINUX=disabled

    2.����ת����������:
        a. echo "1" > /proc/sys/net/ipv4/ip_forward
        b. echo "net.ipv4.ip_forward = 1"  >> /usr/lib/sysctl.d/00-system.conf

������װdocker����
    1.��װdocker��������(ȱʡ1.12.6�汾)
        a. yum install docker
        b. systemctl enable docker.service
        c. systemctl start  docker.service
        d. ���ù��ھ����:
            �޸�/etc/docker/daemon.json �ļ�������� registry-mirrors ��ֵ:
              {
                  "registry-mirrors": ["https://registry.docker-cn.com"]
              }
            �޸ı�������� Docker���� ��ʹ������Ч��
        e.Rancher2.0����kubelet����Ԥ������:
          a).�޸�/etc/systemd/system/multi-user.target.wants/docker.service��MountFlags���ã�ֵ��slave��Ϊshared
          b).systemctl daemon-reload
          c).systemctl restart docker.service

    2.��ǰ��װ��rancher��k8s��������������
        docker rm -f -v $(docker ps -aq) 
        docker volume rm $(docker volume ls)
        rm -rf /var/lib/etcd/
        rm -rf /etc/kubernetes
        docker rmi $(docker images -q)

������װRancher2.0����˻�ͻ���:(��v2.0.8��Ϊ��)
    1.��װdocker-server:
        docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.0.8
        �������¼docker-server��������IP��80�˿�,admin/admin

    2.��װdocker-agent:
        ��docker-server�ļ�Ⱥ���ý����ȡdocker-agent��װ������:
        docker run -d --privileged --restart=unless-stopped --net=host -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:master --server https://192.168.137.131 --token 9455mjxzwfcscmtvdjjp25hvbjpzkrbjwrg87gnk2ws9qfzlp87jhf --ca-checksum 1d382c6629a720f33abac40caa96bf59262349e3a55bb9390fda8bb5967c5ff1 --etcd --controlplane --worker