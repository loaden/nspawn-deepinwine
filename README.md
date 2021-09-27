# nspawn-deepinwine

#### 介绍
利用systemd-nspawn容器跑Deepin 20.2.3或者Debian 10，安装deepinwine，稳定运行QQ、微信、钉钉、深度商店等应用。低内存，高性能，沙盒机制不污染宿主机，支持多用户，理论上可在任何Linux发行版上运行。成功解决MIT-SHM导致的崩溃，好开心！现在很稳定了。

#### 软件架构
软件架构说明：amd64


#### 安装教程

1.  下载或者克隆源码库
2.  终端打开源码库所在路径

#### 使用说明

1.  在源码库脚本所在路径终端执行命令：sudo -s 获取管理员权限
2.  执行：./nspawn-debian.sh 安装 Debian 10
3.  或者：./nspawn-deepin.sh 安装 Deepin 20.2.3
4.  也可以：sudo ./nspawn-debian.sh 这种方式
5.  安装应用，请终端执行：debian-install-qq 或者 deepin-install-qq
6.  更多应用安装，请查看：ls /bin/*-install-*
7.  启动器中查找QQ或者微信启动，也可以终端启动，例如：debian-qq

#### 多系统配置
1.  自动安装的容器支持多系统共享，请提前做好~/.machines的软链接
2.  管理员权限执行：debian-config.sh 或者 deepin-config.sh
3.  如果同时配置两个容器，可以终端管理员权限执行：config.sh
4.  也可以同时安装两个容器：install.sh

#### 高级用法
1.  不禁用宿主机MIT-SHM（稳定性可能下降，但性能好）：sudo DISABLE_HOST_MITSHM=0 ./nspawn-debian.sh
2.  已经安装，只修改配置：sudo DISABLE_HOST_MITSHM=0 ./debian-config.sh
3.  默认会同时禁用宿主机和容器的MIT-SHM扩展：sudo ./nspawn-debian.sh

#### 参与贡献

1.  Fork 本仓库
2.  新建 Feat_xxx 分支
3.  提交代码
4.  新建 Pull Request
