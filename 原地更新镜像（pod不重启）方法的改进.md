原地更换POD中容器的镜像，时间可以缩短到5秒！（OK）

`# kubectl edit deployment/xxxxxx

……

spec:

  terminationGracePeriodSeconds: 0
  
  containers:
  
  - env:
  - 
……

`

grace-period默认30秒，设置为0后（实际是2秒），整体时间大为缩短！

更换语句：

kubectl set image pod/xxxxxxx xxx 容器名称=待更新的镜像名称:TAG

或

kubectl patch pod/xxxxxxx -p '{"spec":{"containers":[{"name":"容器名称","image":"更新后的镜像名称:TAG"}]}}'
