RDP  3秒

1. 虚拟机中安装xrdp：

$ sudo yum install -y epel-release

$ sudo yum install -y xrdp

$ sudo systemctl enable xrdp

$ sudo systemctl start xrdp

2. guacamole-server需要安装freerdp

3. user-mapping.xml配置：

                <connection name="centosvnc-4-rdp">
	
                        <protocol>rdp</protocol>
	
                        <param name="hostname">172.32.150.135</param>
			
                        <param name="port">33004</param>
			
                        <param name="username">root</param>
			
                        <param name="password">root123.</param>
			
                        <param name="security">tls</param>
			
                        <param name="ignore-cert">true</param>
			
                        <param name="disable-auth">true</param>
			
		        <param name="enable-drive">true</param>
			
                        <param name="drive-name">flietrans</param>
			
                        <param name="drive-path">/mnt/disk01/fangjin/projects/rdp-trans</param>
			
                </connection>
		
其中drive-path中的目录是guacemole-server上的一个可读写的目录，该目录将作为一个虚拟盘挂载到虚拟机中（/root/thinclient_drives)

4. 在虚拟机内部，将文件放入Download目录中，将触发文件下载提示

5. 按下Ctrl+Alt+Shift可以触发guacamole menu，其中的“设备”就是上面的挂载盘,点击Shared Driver

6. 还可以用Windows远程桌面访问



