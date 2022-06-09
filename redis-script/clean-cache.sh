# 开始前 cursor 设置为0，中断后可继续
sed -i 's/^local cursor = ".*";/local cursor = "0";/g' xx.lua
echo shellcursor --------------
cat shellcursor
echo clean log --------------
echo clean nottllog --------------
echo > shellcursor
echo > log
echo > nottllog
