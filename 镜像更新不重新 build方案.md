#（原创）基础镜像层替换 （基础镜像更新不重新build案例镜像的镜像/容器更新方案）

思路： 设替换前的基础镜像为A，替换后的基础镜像为B（假设B是在A的基础上制作的）
（1）取A、B的公共层的最上层a
（2）将B中a层以上各层的diff的内容逐层（从低到高）覆盖到a层的diff中
（3）分别观察已有容器和新建容器是否正常（比如登录、桌面显示等）以及是否具备基础镜像B的新增功能


验证过程：验证通过！！

清空镜像
docker image prune -af

# docker pull xxxxxxx/yyyyyy:1.0.20220531
# ll -t
total 4
drwx--x--- 4 root root     72 Jul 20 11:02 74fd8ddf9d61f3045b7eae665ae9fab3bf021003622163917227d7b78d75949b
drwx--x--- 4 root root     55 Jul 20 11:02 88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2
drwx------ 2 root root   4096 Jul 20 11:02 l
drwx--x--- 4 root root     72 Jul 20 11:02 cc0eb011037277e8a6aacf4c2d99eb8a39ca5e515706f98d3ed641833cd8f2b3
drwx--x--- 4 root root     72 Jul 20 11:02 fb9ba854f047312967aed7a91975cdb1679c9efdc9e630b55beeca341688dc57
drwx--x--- 4 root root     72 Jul 20 11:02 3af50b79bdf037af19251f9f420e9809175b160a7c0756e1a4e1563395b27d53
drwx--x--- 4 root root     72 Jul 20 11:00 4794b1a65da7c2cce1b5e44a9290cb3a09ea8412eaf79cc01e679ce94666cd81
drwx--x--- 4 root root     72 Jul 20 11:00 5efde35a14eaa42497fb87af4d5ff854e0e98cec5fd984daabd9869354e4364b
drwx--x--- 4 root root     72 Jul 20 10:59 9650262b63021185c74dd0c620c41259775a1795ac420a408675b38f3180eee0
drwx--x--- 4 root root     72 Jul 20 10:59 6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72
drwx--x--- 4 root root     72 Jul 20 10:59 66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32
drwx--x--- 4 root root     72 Jul 20 10:59 eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5
drwx--x--- 4 root root     72 Jul 20 10:59 f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67
drwx--x--- 4 root root     72 Jul 20 10:59 a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca
drwx--x--- 4 root root     72 Jul 20 10:58 9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0
drwx--x--- 4 root root     72 Jul 20 10:58 2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f
drwx--x--- 4 root root     72 Jul 20 10:58 c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06
drwx--x--- 4 root root     72 Jul 20 10:58 06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217
drwx--x--- 4 root root     72 Jul 20 10:58 151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7
drwx--x--- 3 root root     47 Jul 20 10:58 eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b
drwxr-xr-x 2 root root      6 Jul 20 10:56 tmp
brw------- 1 root root 253, 0 Jul 14 14:28 backingFsBlockDev
# docker inspect cb2dcb22d09b |jq .[0].GraphDriver.Data
{
  "LowerDir": "/var/lib/docker/overlay2/74fd8ddf9d61f3045b7eae665ae9fab3bf021003622163917227d7b78d75949b/diff
:/var/lib/docker/overlay2/cc0eb011037277e8a6aacf4c2d99eb8a39ca5e515706f98d3ed641833cd8f2b3/diff
:/var/lib/docker/overlay2/fb9ba854f047312967aed7a91975cdb1679c9efdc9e630b55beeca341688dc57/diff
:/var/lib/docker/overlay2/3af50b79bdf037af19251f9f420e9809175b160a7c0756e1a4e1563395b27d53/diff
:/var/lib/docker/overlay2/4794b1a65da7c2cce1b5e44a9290cb3a09ea8412eaf79cc01e679ce94666cd81/diff
:/var/lib/docker/overlay2/5efde35a14eaa42497fb87af4d5ff854e0e98cec5fd984daabd9869354e4364b/diff
:/var/lib/docker/overlay2/9650262b63021185c74dd0c620c41259775a1795ac420a408675b38f3180eee0/diff
:/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
:/var/lib/docker/overlay2/66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32/diff
:/var/lib/docker/overlay2/eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5/diff
:/var/lib/docker/overlay2/f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67/diff
:/var/lib/docker/overlay2/a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca/diff
:/var/lib/docker/overlay2/9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0/diff
:/var/lib/docker/overlay2/2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f/diff
:/var/lib/docker/overlay2/c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06/diff
:/var/lib/docker/overlay2/06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217/diff
:/var/lib/docker/overlay2/151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7/diff
:/var/lib/docker/overlay2/eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b/diff",
  "MergedDir": "/var/lib/docker/overlay2/88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2/merged",
  "UpperDir": "/var/lib/docker/overlay2/88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2/diff",
  "WorkDir": "/var/lib/docker/overlay2/88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2/work"
}
##可以看到目录名称是随机的，每次pull（删除后）都不同
# docker pull xxxxxxx/yyyyyy:1.0.20220624
# ll -t
total 4
drwx--x--- 4 root root     55 Jul 20 14:07 6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418
drwx--x--- 4 root root     72 Jul 20 14:07 e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1
drwx------ 2 root root   4096 Jul 20 14:07 l
drwx--x--- 4 root root     72 Jul 20 14:06 882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91
drwx--x--- 4 root root     72 Jul 20 14:06 101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098
drwx--x--- 4 root root     72 Jul 20 14:06 9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41
drwx--x--- 4 root root     72 Jul 20 14:06 b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d
drwx--x--- 4 root root     72 Jul 20 11:02 74fd8ddf9d61f3045b7eae665ae9fab3bf021003622163917227d7b78d75949b
drwx--x--- 4 root root     55 Jul 20 11:02 88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2
drwx--x--- 4 root root     72 Jul 20 11:02 cc0eb011037277e8a6aacf4c2d99eb8a39ca5e515706f98d3ed641833cd8f2b3
drwx--x--- 4 root root     72 Jul 20 11:02 fb9ba854f047312967aed7a91975cdb1679c9efdc9e630b55beeca341688dc57
drwx--x--- 4 root root     72 Jul 20 11:02 3af50b79bdf037af19251f9f420e9809175b160a7c0756e1a4e1563395b27d53
drwx--x--- 4 root root     72 Jul 20 11:00 4794b1a65da7c2cce1b5e44a9290cb3a09ea8412eaf79cc01e679ce94666cd81
drwx--x--- 4 root root     72 Jul 20 11:00 5efde35a14eaa42497fb87af4d5ff854e0e98cec5fd984daabd9869354e4364b
drwx--x--- 4 root root     72 Jul 20 10:59 9650262b63021185c74dd0c620c41259775a1795ac420a408675b38f3180eee0
drwx--x--- 4 root root     72 Jul 20 10:59 6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72
drwx--x--- 4 root root     72 Jul 20 10:59 66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32
drwx--x--- 4 root root     72 Jul 20 10:59 eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5
drwx--x--- 4 root root     72 Jul 20 10:59 f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67
drwx--x--- 4 root root     72 Jul 20 10:59 a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca
drwx--x--- 4 root root     72 Jul 20 10:58 9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0
drwx--x--- 4 root root     72 Jul 20 10:58 2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f
drwx--x--- 4 root root     72 Jul 20 10:58 c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06
drwx--x--- 4 root root     72 Jul 20 10:58 06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217
drwx--x--- 4 root root     72 Jul 20 10:58 151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7
drwx--x--- 3 root root     47 Jul 20 10:58 eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b
drwxr-xr-x 2 root root      6 Jul 20 10:56 tmp
brw------- 1 root root 253, 0 Jul 14 14:28 backingFsBlockDev
# docker inspect 46559f1beeb0 |jq .[0].GraphDriver.Data
{
  "LowerDir": "/var/lib/docker/overlay2/e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/diff
:/var/lib/docker/overlay2/882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91/diff
:/var/lib/docker/overlay2/101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098/diff
:/var/lib/docker/overlay2/9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41/diff
:/var/lib/docker/overlay2/b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff
:/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
:/var/lib/docker/overlay2/66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32/diff
:/var/lib/docker/overlay2/eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5/diff
:/var/lib/docker/overlay2/f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67/diff
:/var/lib/docker/overlay2/a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca/diff
:/var/lib/docker/overlay2/9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0/diff
:/var/lib/docker/overlay2/2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f/diff
:/var/lib/docker/overlay2/c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06/diff
:/var/lib/docker/overlay2/06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217/diff
:/var/lib/docker/overlay2/151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7/diff
:/var/lib/docker/overlay2/eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b/diff",
  "MergedDir": "/var/lib/docker/overlay2/6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418/merged",
  "UpperDir": "/var/lib/docker/overlay2/6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418/diff",
  "WorkDir": "/var/lib/docker/overlay2/6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418/work"
}
#将原始基础镜像最上层保存起来
# \cp -rf 6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/ tmp/
#取最新基础镜像
# docker pull xxxxxxxx/centos7-ttttt:20220628
# ll -t
total 4
drwx--x--- 4 root root     55 Jul 20 14:32 d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d
drwx------ 2 root root   4096 Jul 20 14:32 l
drwxr-xr-x 3 root root     78 Jul 20 14:25 tmp
drwx--x--- 4 root root     55 Jul 20 14:07 6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418
drwx--x--- 4 root root     72 Jul 20 14:07 e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1
drwx--x--- 4 root root     72 Jul 20 14:06 882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91
drwx--x--- 4 root root     72 Jul 20 14:06 101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098
drwx--x--- 4 root root     72 Jul 20 14:06 9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41
drwx--x--- 4 root root     72 Jul 20 14:06 b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d
drwx--x--- 4 root root     72 Jul 20 11:02 74fd8ddf9d61f3045b7eae665ae9fab3bf021003622163917227d7b78d75949b
drwx--x--- 4 root root     55 Jul 20 11:02 88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2
drwx--x--- 4 root root     72 Jul 20 11:02 cc0eb011037277e8a6aacf4c2d99eb8a39ca5e515706f98d3ed641833cd8f2b3
drwx--x--- 4 root root     72 Jul 20 11:02 fb9ba854f047312967aed7a91975cdb1679c9efdc9e630b55beeca341688dc57
drwx--x--- 4 root root     72 Jul 20 11:02 3af50b79bdf037af19251f9f420e9809175b160a7c0756e1a4e1563395b27d53
drwx--x--- 4 root root     72 Jul 20 11:00 4794b1a65da7c2cce1b5e44a9290cb3a09ea8412eaf79cc01e679ce94666cd81
drwx--x--- 4 root root     72 Jul 20 11:00 5efde35a14eaa42497fb87af4d5ff854e0e98cec5fd984daabd9869354e4364b
drwx--x--- 4 root root     72 Jul 20 10:59 9650262b63021185c74dd0c620c41259775a1795ac420a408675b38f3180eee0
drwx--x--- 4 root root     72 Jul 20 10:59 6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72
drwx--x--- 4 root root     72 Jul 20 10:59 66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32
drwx--x--- 4 root root     72 Jul 20 10:59 eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5
drwx--x--- 4 root root     72 Jul 20 10:59 f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67
drwx--x--- 4 root root     72 Jul 20 10:59 a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca
drwx--x--- 4 root root     72 Jul 20 10:58 9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0
drwx--x--- 4 root root     72 Jul 20 10:58 2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f
drwx--x--- 4 root root     72 Jul 20 10:58 c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06
drwx--x--- 4 root root     72 Jul 20 10:58 06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217
drwx--x--- 4 root root     72 Jul 20 10:58 151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7
drwx--x--- 3 root root     47 Jul 20 10:58 eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b
brw------- 1 root root 253, 0 Jul 14 14:28 backingFsBlockDev
# docker inspect 0f6f5487d630 |jq .[0].GraphDriver.Data
{
  "LowerDir": "/var/lib/docker/overlay2/e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/diff
:/var/lib/docker/overlay2/882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91/diff
:/var/lib/docker/overlay2/101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098/diff
:/var/lib/docker/overlay2/9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41/diff
:/var/lib/docker/overlay2/b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff
:/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
:/var/lib/docker/overlay2/66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32/diff
:/var/lib/docker/overlay2/eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5/diff
:/var/lib/docker/overlay2/f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67/diff
:/var/lib/docker/overlay2/a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca/diff
:/var/lib/docker/overlay2/9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0/diff
:/var/lib/docker/overlay2/2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f/diff
:/var/lib/docker/overlay2/c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06/diff
:/var/lib/docker/overlay2/06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217/diff
:/var/lib/docker/overlay2/151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7/diff
:/var/lib/docker/overlay2/eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b/diff",
  "MergedDir": "/var/lib/docker/overlay2/d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/merged",
  "UpperDir": "/var/lib/docker/overlay2/d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/diff",
  "WorkDir": "/var/lib/docker/overlay2/d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/work"
}
#将基础镜像0621和0628的公共最上层保存起来
# \cp -rf e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/ tmp/
#实验开始
#起一个容器
# docker run -dt -v=/sys/fs/cgroup:/sys/fs/cgroup:ro  --name ddd -p 44000:3389 -p 44002:22 --hostname master  xxxxxxxx/yyyyy:1.0.20220624
a471967ac0e5a4bc3128fefd0ca05303c6fa9e3b97676c8541a426bdbf5581da
# ll -t
total 4
drwx--x--- 5 root root     69 Jul 20 14:53 174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234
drwx--x--- 4 root root     72 Jul 20 14:53 174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234-init
drwx------ 2 root root   4096 Jul 20 14:53 l
drwx--x--- 4 root root     72 Jul 20 14:53 6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418
drwxr-xr-x 4 root root    150 Jul 20 14:48 tmp
drwx--x--- 4 root root     55 Jul 20 14:32 d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d
drwx--x--- 4 root root     72 Jul 20 14:07 e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1
drwx--x--- 4 root root     72 Jul 20 14:06 882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91
……
# docker ps
CONTAINER ID   IMAGE                                                    COMMAND                  CREATED              STATUS              PORTS                                            NAMES
a471967ac0e5   xxxxxxxxxx/yyyyy:1.0.20220624   "/bin/bash /tools/en…"   About a minute ago   Up About a minute   0.0.0.0:44002->22/tcp, 0.0.0.0:44000->3389/tcp   ddd
# docker inspect a471967ac0e5 |jq .[0].GraphDriver.Data
{
  "LowerDir": "/var/lib/docker/overlay2/174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234-init/diff
:/var/lib/docker/overlay2/6af8a4f2737ee31dcce75efb077d65383415e76912f39489b2a70702f86e9418/diff
:/var/lib/docker/overlay2/e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/diff
:/var/lib/docker/overlay2/882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91/diff
:/var/lib/docker/overlay2/101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098/diff
:/var/lib/docker/overlay2/9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41/diff
:/var/lib/docker/overlay2/b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff
:/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
:/var/lib/docker/overlay2/66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32/diff
:/var/lib/docker/overlay2/eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5/diff
:/var/lib/docker/overlay2/f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67/diff
:/var/lib/docker/overlay2/a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca/diff
:/var/lib/docker/overlay2/9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0/diff
:/var/lib/docker/overlay2/2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f/diff
:/var/lib/docker/overlay2/c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06/diff
:/var/lib/docker/overlay2/06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217/diff
:/var/lib/docker/overlay2/151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7/diff
:/var/lib/docker/overlay2/eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b/diff",
  "MergedDir": "/var/lib/docker/overlay2/174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234/merged",
  "UpperDir": "/var/lib/docker/overlay2/174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234/diff",
  "WorkDir": "/var/lib/docker/overlay2/174b0f4f29fce0011ed6a3eae7c7e6e3c297b50ea5ef87d114603d98c2826234/work"
}
# docker exec -it ddd cat /home/hadoop/.Xclients
#!/bin/bash

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -dx
exec xfce4-session

#将0624基础镜像最上层的.Xclients拷贝到0621基础镜像最上层的diff下
# cd e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/
# ll
total 8
-rw------- 1 root root   0 Jul 20 14:32 committed
drwxr-xr-x 6 root root  51 Jul 20 14:06 diff
-rw-r--r-- 1 root root  26 Jul 20 14:06 link
-rw-r--r-- 1 root root 434 Jul 20 14:06 lower
drwx------ 2 root root   6 Jul 20 14:06 work
# cd diff/
# ll
total 0
drwxr-xr-x 3 root root  72 Jun 21 09:50 etc
dr-xr-x--- 2 root root  43 Jun 21 09:50 root
drwxrwxrwt 2 root root 246 Jun  1 11:50 tmp
drwxr-xr-x 4 root root  28 May 20 13:38 var
# \cp -af ../../d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/diff/home/ ./  #一定要用af参数
# ll
total 0
drwxr-xr-x 3 root root  72 Jun 21 09:50 etc
drwxr-xr-x 3 root root  20 Jul 20 15:04 home
dr-xr-x--- 2 root root  43 Jun 21 09:50 root
drwxrwxrwt 2 root root 246 Jun  1 11:50 tmp
drwxr-xr-x 4 root root  28 May 20 13:38 var
# ll home/hadoop/
total 0
# cat home/hadoop/.Xclients 
#!/bin/bash

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export GTK_IM_MODULE=xim
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=xim
ibus-daemon -dx
exec xfce4-session
#检查容器
# docker restart ddd
ddd
# docker exec -it ddd cat /home/hadoop/.Xclients
#!/bin/bash

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -dx
exec xfce4-session
#容器restart无效
# docker stop ddd
ddd
# docker start ddd
ddd
# docker exec -it ddd cat /home/hadoop/.Xclients
#!/bin/bash

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
export GTK_IM_MODULE=xim
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=xim
ibus-daemon -dx
exec xfce4-session
#容器先stop再start OK！远程桌面登录也OK！
#将0628最上层diff内容全部拷贝到0621最上层diff下
# \cp -af ../../d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/diff/* ./
# docker stop ddd
ddd
# docker start ddd
ddd
#注：要在浏览器中输入中文还需要执行ibus-daemon -drx（新建的容器也需要），另因为容器上层已经有/etc/profile和/etc/xrdp/xrdp.init，故相关文件的修改无效
#继续实验上次失败的场景
# docker run -dt -v=/sys/fs/cgroup:/sys/fs/cgroup:ro  --name ddd -p 44000:3389 -p 44002:22 --hostname master  xxxxxx/yyyyy:1.0.20220531
84135250bcc7dc112837cdc29651fefb6ab58b19cb22329a95e9398e2b8512fc
# docker ps
CONTAINER ID   IMAGE                                                    COMMAND                  CREATED          STATUS          PORTS                                            NAMES
84135250bcc7   xxxxxx/yyyyy:1.0.20220531   "/bin/bash /tools/en…"   43 seconds ago   Up 42 seconds   0.0.0.0:44002->22/tcp, 0.0.0.0:44000->3389/tcp   ddd
# docker inspect 84135250bcc7 |jq .[0].GraphDriver.Data
{
  "LowerDir": "/var/lib/docker/overlay2/000e12c5fd81e11ff70ed734647523baf3c2690e2d7bfec6216e45dcf07efbda-init/diff
:/var/lib/docker/overlay2/88850d6cbd662b97b9e32afe799af9c9f490c5bbd45dfb5a873dd872d0eddaa2/diff
:/var/lib/docker/overlay2/74fd8ddf9d61f3045b7eae665ae9fab3bf021003622163917227d7b78d75949b/diff
:/var/lib/docker/overlay2/cc0eb011037277e8a6aacf4c2d99eb8a39ca5e515706f98d3ed641833cd8f2b3/diff
:/var/lib/docker/overlay2/fb9ba854f047312967aed7a91975cdb1679c9efdc9e630b55beeca341688dc57/diff
:/var/lib/docker/overlay2/3af50b79bdf037af19251f9f420e9809175b160a7c0756e1a4e1563395b27d53/diff
:/var/lib/docker/overlay2/4794b1a65da7c2cce1b5e44a9290cb3a09ea8412eaf79cc01e679ce94666cd81/diff
:/var/lib/docker/overlay2/5efde35a14eaa42497fb87af4d5ff854e0e98cec5fd984daabd9869354e4364b/diff
:/var/lib/docker/overlay2/9650262b63021185c74dd0c620c41259775a1795ac420a408675b38f3180eee0/diff
:/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
:/var/lib/docker/overlay2/66cf4ce469d049440e51f99d333735534380cdd433d4ebde78bb8f928108db32/diff
:/var/lib/docker/overlay2/eefd0fc1960b04cdda0ccc4f5284e4610fcfd48d74455972405566fe25c64bb5/diff
:/var/lib/docker/overlay2/f18894148c9048b9bcca717a4ab81814cd424f763edb1d1297e51ee2962eeb67/diff
:/var/lib/docker/overlay2/a1e0efe5935df8c71bb26542ee1b180be28ee8ec3a27c581ab2d1346cfc6fdca/diff
:/var/lib/docker/overlay2/9415a56ff4a5e4253d5d918c635acebc302e351d9f8c8047a2096c372878e3c0/diff
:/var/lib/docker/overlay2/2deb4d60e4b9486df07a23136d8fdb119db2724292abc645480c5e4b0dd2ca9f/diff
:/var/lib/docker/overlay2/c56dc7ca64c2957488cc92cb7470c400ae8db756fb7d46a596f435a2b2339c06/diff
:/var/lib/docker/overlay2/06183e4f4a7537cfec778fb3445a8d094c794151ed6c4869a58ddeca5aa3c217/diff
:/var/lib/docker/overlay2/151487d22f34168609b5dd8493e5104a52d0b0a737e50d26301976f48a1782f7/diff
:/var/lib/docker/overlay2/eb8b5371975d44b6e12bd5662326e036a0c125aa6e6513680a32e55219246f7b/diff",
  "MergedDir": "/var/lib/docker/overlay2/000e12c5fd81e11ff70ed734647523baf3c2690e2d7bfec6216e45dcf07efbda/merged",
  "UpperDir": "/var/lib/docker/overlay2/000e12c5fd81e11ff70ed734647523baf3c2690e2d7bfec6216e45dcf07efbda/diff",
  "WorkDir": "/var/lib/docker/overlay2/000e12c5fd81e11ff70ed734647523baf3c2690e2d7bfec6216e45dcf07efbda/work"
}
# cd 6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/
# cd diff
# pwd
/var/lib/docker/overlay2/6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72/diff
# \cp -af ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/* ./
cp: cannot overwrite directory ‘./home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6’ with non-directory
cp: cannot overwrite directory ‘./tmp/ssh-reHddQvhTxQc’ with non-directory
cp: cannot overwrite directory ‘./var/log/tuned’ with non-directory
# ll ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6
c--------- 1 root root 0, 0 Jul 20 14:06 ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6
# ll ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/tmp/ssh-reHddQvhTxQc
c--------- 1 root root 0, 0 Jul 20 14:06 ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/tmp/ssh-reHddQvhTxQc
# ll ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/var/log/tuned
c--------- 1 root root 0, 0 Jul 20 14:06 ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/var/log/tuned
# ll ./home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6
total 0
# ll -a ./home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6
total 0
drwx------ 2 bdapp bdapp  6 May 20 13:38 .
drwx------ 4 bdapp bdapp 94 Jun  1 09:46 ..
# ll -a ./tmp/ssh-reHddQvhTxQc
total 0
drwx------ 2 bdapp bdapp   6 May 20 13:38 .
drwxrwxrwt 5 root  root  225 Jun  1 11:03 ..
# ll -a ./var/log/tuned.
ls: cannot access ./var/log/tuned.: No such file or directory
# ll -a ./var/log/tuned
total 4
drwxr-xr-x 2 root root  23 May 20 13:38 .
drwxr-xr-x 3 root root 269 Jun  1 11:06 ..
-rw-r--r-- 1 root root  95 May 20 13:38 tuned.log
# rm -rf ./home/hadoop/.config/google-chrome/Default/blob_storage/ff60cd8c-7c6c-43cd-8694-19ad43febcb6
# rm -rf ./tmp/ssh-reHddQvhTxQc
# rm -rf ./var/log/tuned
# \cp -af ../../b0a43f60a66aade075ed8b66403449849168ab3a1ed41249fb7aea19c081400d/diff/* ./
# \cp -af ../../9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41/diff/* ./
cp: cannot overwrite directory ‘./home/hadoop/.pcsc10’ with non-directory
# rm -rf ./home/hadoop/.pcsc10
# \cp -af ../../9166df54f31cce3e2fd531522b2d739301db2020a57bd760edf74a637440fc41/diff/* ./
# \cp -af ../../101086c5ff28566b11ba7cf6d011c9ff83df8b4269772fd3a98c6d9122f18098/diff/* ./
# \cp -af ../../882cebdd7ae24832773e06321382f8a1fb2b53cd7924d900db223f0671bddb91/diff/* ./
# \cp -af ../../e32834b10c345f8b01082effcd5c644cbc6834118464f69d09623915d0c63ec1/diff/* ./
# \cp -af ../../d09c41116e1abfcb2c88d9baa037de2b2afcb872089b84181c58a85dc4538f2d/diff/* ./
# docker stop ddd
ddd
# docker rm ddd（手误！）
ddd
# docker run -dt -v=/sys/fs/cgroup:/sys/fs/cgroup:ro  --name ddd -p 44000:3389 -p 44002:22 --hostname master  xxxxxx/yyyyy:1.0.20220531
8defd1d7a4023981c7159891644a2062a195a73e302d0d7558d2d06f47c4f7e7
#容器先stop再start OK！远程桌面登录也OK！但ibus-daemon -drx仍需要在容器内手工执行！
即使将6a641800fa8c66e6319b7921e12fa9ee9386f80807526f61ea1806586a93ff72中的.Xclients中改成ibus-daemon -drx，仍然不行？？
手工单起0628镜像也不行，可能是docker run的问题
# docker run -dt -v=/sys/fs/cgroup:/sys/fs/cgroup:ro  --name ddd -p 44000:3389 -p 44002:22 --hostname master  xxxxxx/yyyyy:1.0.20220531
27227b864afa890794b43e8871e8b1e75839db9a777633fe2c23bb8954c28af2
# docker exec -it ddd /bin/bash
# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  3 17:47 ?        00:00:00 /usr/sbin/init
root        21     1  0 17:47 ?        00:00:00 /usr/sbin/xrdp-sesman --nodaemon
root        22     1  0 17:47 ?        00:00:00 /usr/sbin/xrdp --nodaemon
root        25     1  0 17:47 ?        00:00:00 /usr/lib/systemd/systemd-journald
root        38     1  0 17:47 ?        00:00:00 /usr/sbin/sshd -D
root        39     1  0 17:47 ?        00:00:00 /usr/sbin/rsyslogd -n
root        40     1  0 17:47 ?        00:00:00 /usr/lib/systemd/systemd-logind
dbus        41     1  0 17:47 ?        00:00:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --sys
root        48     1  0 17:47 console  00:00:00 /sbin/agetty --noclear --keep-baud console 115200 38400 9600 vt220
root        50     0 28 17:47 pts/1    00:00:00 /bin/bash
root        68    50  0 17:47 pts/1    00:00:00 ps -ef
#貌似除基本镜像以外的其他进程未启动？？？ 

另一台机器上：
# docker run -dt -v=/sys/fs/cgroup:/sys/fs/cgroup:ro  --name ddd -p 44000:3389 -p 44002:22 --hostname master  xxxxxx/yyyyy:1.0.20220531
0111d8c5aa8f71fc82c0d6b6a83bd50fee003297ecee50369f688067e31350b6
# docker exec -it ddd /bin/bash
# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  5 17:54 ?        00:00:00 /usr/sbin/init
root        22     1  0 17:54 ?        00:00:00 /usr/lib/systemd/systemd-journald
root        37     1  0 17:54 ?        00:00:00 /usr/sbin/irqbalance --foreground
dbus        38     1  0 17:54 ?        00:00:00 /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --sys
polkitd     40     1  0 17:54 ?        00:00:00 /usr/lib/polkit-1/polkitd --no-debug
root        41     1  0 17:54 ?        00:00:00 /usr/lib/systemd/systemd-logind
root        43     1  0 17:54 ?        00:00:00 /usr/sbin/crond -n
root        50     1  0 17:54 console  00:00:00 /sbin/agetty --noclear --keep-baud console 115200 38400 9600 vt220
root        54     1  6 17:54 ?        00:00:00 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
root        59     1  0 17:54 ?        00:00:00 /usr/sbin/sshd -D
root        61     1  0 17:54 ?        00:00:00 /usr/sbin/xrdp-sesman --nodaemon
root        62     1  0 17:54 ?        00:00:00 /usr/sbin/xrdp --nodaemon
root        63     1  0 17:54 ?        00:00:00 /usr/sbin/rsyslogd -n
root        82     0 18 17:54 pts/1    00:00:00 /bin/bash
root       101    54  0 17:54 ?        00:00:00 /usr/bin/python2 -Es /usr/sbin/firewalld --nofork --nopid
root       102    82  0 17:54 pts/1    00:00:00 ps -ef

#拉取其他镜像不会覆盖已手工更新过的子目录！！！即更改过长期有效
#当删除所有用到该更新过的子目录的镜像时，该子目录也会被删除，因此删除镜像操作要注意！


例子：
开发机：
# ./getbasediff.sh base-XXXXX 20220621 base-XXXXX 20220726
# ll
total 4
drwxr-xr-x 3 root root   66 Aug  2 16:38 BASE-20220621
drwxr-xr-x 3 root root   66 Aug  3 08:55 BASE-20220726
-rwxr-xr-x 1 root root 1462 Aug  3 08:48 getbasediff.sh
# ll BASE-20220726/
total 809188
-rw-r--r--  1 root root 828605076 Aug  3 08:56 BASE-20220726-diff.tar.gz
drwxr-xr-x 17 root root       224 Aug  3 08:55 diff
-rw-r--r--  1 root root         0 Aug  3 08:55 log.log

生产机：
# scp root@xx.xx.xx.xx:/var/lib/docker/overlay2/tmp/BASE-20220726/BASE-20220726-diff.tar.gz ./
root@xx.xx.xx.xx's password: 
microk8s is not running, try microk8s start
BASE-20220726-diff.tar.gz                                                        100%  790MB  72.6MB/s   00:10   
# ./updatebase.sh 20220621 20220726
# cat baseimg.properties 
base.dir=/var/lib/docker/overlay2/2cb780e1dbb2fbf0dd6fe6098cbad94598c20f3062dcc5142ff5a1158f787847/diff
base.ver=20220726

















