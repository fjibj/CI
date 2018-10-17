Linux服务器批量建互信：

1.执行 **bin/root_ssh_double_trust.sh**

2.预先在**conf/ip_user_pwd_root**中配置与当前所在机器要建立互信机器的IP、用户名、密码

3.目前该脚本主要针对**redhat**操作系统，其他操作系统的需要作相应修改(check_install_expect.sh)
