## Redis集群模式简介

Redis  在3.0版本前只支持单实例模式，可使用 哨兵（sentinel）机制来监控主从模式下各节点之间的状态，来解决单点故障，但没法满足高并发业务的需求，

Redis 在 3.0 版本以后就推出了**Redis Cluster**分布式解决方案，提供了比之前版本的哨兵模式更高的性能与可用性。使得Redis集群不需要 sentinel哨兵也能完成节点移除和故障转移的功能。需要将毎个节点设置成集群模式,这种集群模式没有中心节点,可水平扩展,据官方文档称可以线性扩展到1000节点。 redis集群的性能和高可用性均优于之前版本的哨兵模式,且配置非常简单。

## 脚本功能介绍

### `Redis Cluster（Bare Metal）Deploy.sh`

提供了自动**编译部署Redis Cluster分布式集群**的功能，同时也支持伪分布式测试环境快速搭建，在使用之前需要按需修改脚本内的环境变量

> ~~~
> # 版本
> Redis_VERSION=6.2.5
> rvm_version=2.3.0
> # 工作目录 下载解压到此
> Work_Dir=/usr/local/src
> # 安装目录
> Products_Dir=/usr/local/redis
> # 启动端口
> Port=6379
> # bind地址
> Bind_IP=0.0.0.0
> # 跳过初始化 如果构建伪分布式集群 第一次初始化后可将此参数开启加快后续节点部署速度
> # skip=1
> ~~~

### `redis-manager.sh`

提供方便的Redis管理功能

支持参数有：`redis-manager.sh [start|stop|status|restart|log|config|pid]`

## 脚本使用方式

使用curl免下载运行

```
curl -L songjinfeng.com/Redis Cluster（Bare Metal）Deploy.sh | bash 
curl -L songjinfeng.com/redis-manager.sh | bash -s  [start|stop|status|restart|log|config|pid]
```

使用gti clone到本地运行

~~~
git clone https://github.com/SJFCS/Redis-Cluster-Bare-Metal-Deploy-Shell.git
~~~

## redis一键安装脚本

~~~bash
#!/bin/bash
#########################################################
# Author        : SongJinfeng
# Email         : Song.Jinfeng@outlook.com
# Last modified : 2021-09-26
# Filename      : Redis Cluster（Bare Metal）Deploy.sh
# Description   : 每台Redis Cluster节点都要运行，你可以通过修改Products_Dir和Port实现部署伪分布式集群
#########################################################
# 版本
Redis_VERSION=6.2.5
rvm_version=2.3.0
# 工作目录 下载解压到此
Work_Dir=/usr/local/src
# 安装目录
Products_Dir=/usr/local/redis
# 启动端口
Port=6379
# bind地址
Bind_IP=0.0.0.0
# 跳过初始化 如果构建伪分布式集群 第一次初始化后可将此参数开启加快后续节点部署速度
# skip=1
function install_redis () {
##########################################################初始化过程可能会因为网络问题失败，可调沟通网络手动执行。
if [ $skip = "" ]; then
yum install wget gcc ruby rubygems -y
##########################################更新ruby前需要更新rvm
#wget https://rvm.io/mpapis.asc && gpg2 --import mpapis.asc
#wget https://rvm.io/pkuczynski.asc && gpg2 --import pkuczynski.asc
curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable
source /usr/local/rvm/scripts/rvm
#find / -name rvm -print
#rvm list known
rvm install ${rvm_version}
rvm use ${rvm_version}
ruby --version
#rvm remove 2.0.0
###########################################安装 redis.gem
gem sources -a https://rubygems.org
# 安装最新版需要更新ruby
gem install redis 
#使用3.0.0版本不需要更新ruby
#gem install redis --version 3.0.0
#也可以手动下载redis gem
#wget https://rubygems.global.ssl.fastly.net/gems/redis-3.2.1.gem
#gem install -l ./redis-3.2.1.gem
fi
#################################################################################################
        cd ${Work_Dir}
        if [ ! -f redis-${Redis_VERSION}.tar.gz ]; then
           wget https://download.redis.io/releases/redis-${Redis_VERSION}.tar.gz
        fi
        tar -xvf /usr/local/src/redis-${Redis_VERSION}.tar.gz
        cd redis-${Redis_VERSION}
        mkdir -p ${Products_Dir}/var/data
        make PREFIX=${Products_Dir} install
        rsync -avz redis.conf  ${Products_Dir}
        sed -i 's/daemonize no/daemonize yes/g' ${Products_Dir}/redis.conf
        sed -i 's/^# cluster-enabled yes/cluster-enabled yes/g' ${Products_Dir}/redis.conf
        sed -i 's/^# cluster-node-timeout 15000/cluster-node-timeout 15000/g' ${Products_Dir}/redis.conf
        sed -i 's/appendonly no/appendonly yes/g' ${Products_Dir}/redis.conf
        sed -i "s/^port 6379/port ${Port}/g" ${Products_Dir}/redis.conf
        sed -i "s/^bind 127.0.0.1 -::1/bind ${Bind_IP}/g" ${Products_Dir}/redis.conf
        sed -i "s@^dir.*@dir ${Products_Dir}/var/data@" ${Products_Dir}/redis.conf
        sed -i "s@pidfile.*@pidfile ${Products_Dir}/var/redis-${Port}.pid@" ${Products_Dir}/redis.conf
        sed -i "s@logfile.*@logfile ${Products_Dir}/var/redis.log@" ${Products_Dir}/redis.conf
        sed -i "s/# cluster-config-file nodes-6379.conf/cluster-config-file nodes-${Port}.conf/g" ${Products_Dir}/redis.conf

 #################################################################################################
}

install_redis
# start
/usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf

echo “Redis节点全部建好后，你可以通过以下命令进行创建集群”
echo “${Products_Dir}/bin/redis-cli --cluster-replicas 1 --cluster create IP:Port”
echo "注意：Redis Cluster最低要求是3个主节点，如果需要集群需要认证，则在最后加入 -a xx 即可。"
echo "旧版本使用redis-trib.rb create --replicas 1 IP:Port"
echo "--replicas 计算方法为master数量÷slave数量"
echo "ip:port 顺序为 主1 主2 主3 从1 从2 从3"
~~~

>**本脚本自动修改了如下参数**
>
>~~~bash
>daemonize yes
>cluster-enabled yes（启动集群模式）
>cluster-node-timeout 15000
>appendonly yes
>
>port {PORT}（每个节点的端口号）
>bind {IP}（绑定当前机器 IP，方便redis集群定位机器，不绑定可能会出现循环查找集群节点机器的情况）
>dir  （数据文件存放位置，伪集群模式要指定不同目录不然会丢失数据）
>pidfile *.pid      （pid 文件要对应）
>cluster-config-file *.conf （配置文件要对应）
>



> **更多配置参考**:
>
> ~~~
> #masterauth "20180408"                        #master设置密码保护，即slave连接master时的密码
> #requirepass "20180408"                       #设置Redis连接密码，如果配置了连接密码，客户端在连接Redis时需要通过AUTH <password>命令提供密码，默认关闭
> appendonly yes                                #打开aof持久化
> appendfilename "appendonly.aof"
> appendfsync everysec                          # 每秒一次aof写
> 注意：
> 上面配置中masterauth和requirepass表示设置密码保护，如果设置了密码，则连接redis后需要执行"auth 20180408"密码后才能操作其他命令。这里我不设置密码。
> #slave
> slaveof 192.168.10.202 6379                  #相对主redis配置，多添加了此行       
> slave-serve-stale-data yes
> slave-read-only yes                          #从节点只读，不能写入
> ~~~

### **伪分布式**

如果你需要伪分布式做测试则可以把 Products_Dir和Port修改为你想要的，从而在一台主机上创建多个redis实例

修改变量后，调用脚本中的install_redis函数即可

> **例子：** 
>
> Products_Dir=/usr/local/redis8001
> Port=8001
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> skype=1
>
> Products_Dir=/usr/local/redis8002
> Port=8002
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis8003
> Port=8003
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis8004
> Port=8004
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis8005
> Port=8005
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf
>
> Products_Dir=/usr/local/redis8006
> Port=8006
> install_redis
> /usr/local/redis/bin/redis-server ${Products_Dir}/redis.conf

### 手动创建集群

脚本会自动帮你运行Redis实例，然后你需要手动指定它们之间的主从关系，命令如下：

```bash
${Products_Dir}/bin/redis-cli --cluster-replicas 1 --cluster create 10.0.0.10:8001 10.0.0.10:8002 10.0.0.10:8003 10.0.0.10:8004 10.0.0.10:8005 10.0.0.10:8006
```

> 注意：Redis Cluster最低要求是3个主节点，如果需要集群需要认证，则在最后加入 -a xx 即可。
> 旧版本使用`redis-trib.rb create --replicas 1 IP:Port`
> `--replicas` 计算方法为master数量÷slave数量 
> `ip:port` 顺序为 主1 主2 主3 从1 从2 从3
>
> 确认主从关系无误后输入yes进行创建

![image-20210926163417769](https://image-fusice.oss-cn-hangzhou.aliyuncs.com/image/Untitled/2021.09.26-16:34:19-image-20210926163417769.png)

## redis服务管理脚本

~~~bash
#!/bin/bash
#########################################################
# Author        : SongJinfeng
# Email         : Song.Jinfeng@outlook.com
# Last modified : 2021-09-26
# Filename      : redis-manager.sh
# Description   : redis服务管理脚本，支持参数有 start|stop|status|restart|log|config|pid
#########################################################
# 安装目录
Products_Dir=/usr/local/redis8006
# 启动端口
Port=8006
redis_server=${Products_Dir}/bin/redis-server
redis_cli=${Products_Dir}/bin/redis-cli
redis_benchmark=${Products_Dir}/bin/redis-benchmark
pidfile=${Products_Dir}/var/redis-${Port}.pid
logfile=${Products_Dir}/var/redis.log
cfgfile=${Products_Dir}/redis.conf
prog="Redis Server"
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0
# Source redis
[ -f /etc/sysconfig/redis ] && . /etc/sysconfig/redis

start() {
    [ -x $redis ] || exit 5
    [ -f $conf_file ] || exit 6
    echo -n $"Starting $prog: " && echo
    ${redis_server} ${cfgfile}
    ss -lntp |grep ${Port}
}
  
stop() {
    echo -n $"Stopping $prog: " && echo
#   pid=`cat ${pidfile}`
#   kill ${pid}
    ${redis_cli} -c -p ${Port} shutdown
   ss -lntp |grep ${Port}
}
  
restart() {
    stop
    start
}

log() {
tail -f ${logfile} -n 50
}

config() {
vi ${cfgfile}
}
pid() {
cat ${pidfile}
}
case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart)
        $1
        ;;
    log)
        $1
        ;;
    config)
        $1
        ;;
    pid)
        $1
        ;;     
    *)
        echo $"Usage: $0 {start|stop|status|restart|log|config|pid}"
        exit 2
esac
~~~

### 集群验证

~~~
集群验证
./redis-cli -c -h -p (-c表示集群模式，指定IP和端口)
如：${Products_Dir}/bin/redis-cli -c -h 10.0.0.10 -p 8001
查看集群信息：cluster info 
查看节点列表：cluster nodes
进行数据操作验证
set key value
get key
模拟宕机验证主从切换
关闭集群需要逐个关闭：
/usr/local/redis/bin/redis-cli -c -h 10.0.0.10 -p 800* shutdown
mkdir -p ${Products_Dir}/Redis{6001..6006}/{data,var} ${Products_Dir}/bin/
echo ${Products_Dir}/Redis{6001..6006} | xargs -n 1 cp -v /usr/local/src/redis-${Redis_VERSION}/redis.conf

ps -ef |grep redis
netstat -lunpl |grep 6379
/usr/local/redis/bin/redis-cli
pkill redis-server
/usr/local/redis/bin/redis-cli shutdown
~~~

## 水平扩展

暂不支持（后续补充，敬请期待）

## FQA

脚本初始化阶段会更新和安装ruby、rvm、gem 国内网络偶尔可能会导下载失败，可参照脚本初始化阶段注释，进行手动初始化操作。
