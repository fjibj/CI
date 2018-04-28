FROM 10.45.59.250/base/tomcat7_jdk17
MAINTAINER geng.ziqiang
#copy war into image
ADD ficusbrace.war /tomcat/webapps/
#expose port
EXPOSE 8080
ENV LANG zh_CN.GBK
ENV JAVA_OPTS "-Dfile.encoding=GBK -Xms1024m -Xmx2048m -XX:PermSize=128M -XX:MaxPermSize=512m"
#define entry point which will be run first when the container starts up
