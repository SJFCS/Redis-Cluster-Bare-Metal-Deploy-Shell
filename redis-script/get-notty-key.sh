host=127.0.0.1
port=6379
password=password
shellcursor=1
while [ "$shellcursor" != "0" ]
do
    redis-cli -h $host -p $port -a $password --eval xx.lua  2> /dev/null > log
    # 获取reids scan cursor
    cat log |sed -n "1p" >shellcursor
    shellcursor=`cat shellcursor`

    # 记录 no ttl key
    sed -i '1d' log
    cat log >> nottllog

    # 更新 lua 脚本
    sed -i 's/^local cursor = ".*";/local cursor = "'"$shellcursor"'";/g' xx.lua
    cat xx.lua |grep "local cursor"
done
    
