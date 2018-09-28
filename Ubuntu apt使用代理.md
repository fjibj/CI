Ubuntu apt-get使用代理：    
在/etc/apt/apt.conf文件中加入如下内容（没有的话新建一个）：     
$ cat /etc/apt/apt.conf    
Acquire::http::proxy "http://192.168.1.100:808/";     
Acquire::ftp::proxy "ftp://192.168.1.100:808/";     
Acquire::https::proxy "https://192.168.1.100:808/";      

如果是要使用用户名密码登录代理服务器，需要按以下格式：    
http://username:password@yourproxyaddress:proxyport      
OK，可以愉快地通过代理使用apt-get了。
