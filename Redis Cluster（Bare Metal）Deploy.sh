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