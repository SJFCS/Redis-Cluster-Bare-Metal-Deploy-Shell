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
pidfile=${Products_Dir}/var/redis-${Pod}.pid
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