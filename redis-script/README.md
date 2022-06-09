##  使用前改链接参数和扫描步长，阿里云集群版对脚本有检查限制需进行调整
##  在三千万级别的redis集群做过验证
```
host=
port=6379
password=
redis-cli -h $host -p $port -a $password --eval xx.lua 
```
```
# 终止脚本 script kill
# docker run --network=host -v$PWD:/app -d --name myredis -p 6379:6379 redis --requirepass "password"
# redis-cli -h 127.0.0.1 -p 6379 -a password --eval get-no-ttl-key.lua 
# kubectl run tmp-shell-redis  --restart=Never --rm -i --tty --image docker-registry-registry-vpc.cn-hangzhou.cr.aliyuncs.com/mirror/redis-get-nottl-key:v2  -- bash

apt-get update
apt-get install vim
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
apk add vim 
```
