JDK8的安装   

安装ppa    
  sudo add-apt-repository ppa:webupd8team/java     
  sudo apt-get update    

安装jdk     
  sudo apt-get install oracle-java8-installer    

验证安装是否成功    
  java -version   

成功后会出现：     
  java version “1.8.0_171”      
  Java(TM) SE Runtime Environment (build 1.8.0_171-b11)       
  Java HotSpot(TM) 64-Bit Server VM (build 25.171-b11, mixed mode)     


如果系统中安装有多个JDK版本，则可以通过如下命令设置系统默认JDK为Oracle JDK 8：       
  sudo update-java-alternatives -s java-8-oracle      

设置JAVA_HOME环境变量    

经过上述过程时候JAVA_HOME对应的位置应该在/usr/lib/jvm/java-8-oracle处。       

编辑/etc/profile文件，在文件末尾添加如下3行：     
  export JAVA_HOME=/usr/lib/jdk1.8.0_45       
  export CLASSPATH=.:JAVAHOME/lib:JAVAHOME/lib:JAVA_HOME/lib:JAVA_HOME/jre/lib:$CLASSPATH     

这里没有在环境变量PATH中添加JAVA信息的原因是：之前通过apt安装的时候已经设置好了，所以不用添加。       
并执行：    
  source /etc/profile    

此时可以通过echo $JAVA_HOME来验证结果。     
在/etc/profile中编写的内容在系统启动时会执行一次，这样能够确保JAVA_HOME环境变量一直存在在系统中。     
