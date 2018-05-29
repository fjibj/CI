查找 某个 jar:  find /  -name  *spring*web*.jar

-p 指定端口号（默认11211）  
-m 指定最大使用内存大小（默认64MB）  
-t 线程数（默认4）  
-l 连接的IP地址, 默认是本机  
-d start 启动memcached服务  
-d restart 重起memcached服务  
-d stop|shutdown 关闭正在运行的memcached服务  
-m 最大内存使用，单位MB。默认64MB  
-M 内存耗尽时返回错误，而不是删除项  
-c 最大同时连接数，默认是1024
-f 块大小增长因子，默认是1.25
-n 最小分配空间，key+value+flags默认是48


** find . -name '*.jar' -exec bash -c 'jar -tf {} | grep -iH --label {} org/apache/hadoop/mapreduce/Job.class' \; **
用来查找当前目录及子目录下的哪个jar包中包含有org.apache.hadoop.mapreduce.Job类

是当前目录下子目标也一并查找了么@方进 
方进(185482899)  11:02:51
是的
曲丽丽(3455907)  11:04:31
棒棒，这样以后现场找class就方便了。。
