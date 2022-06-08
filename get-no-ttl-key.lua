# redis-cli -h 127.0.0.1 -p 6379 -a password --eval get-no-ttl-key.lua 
local result = {};
local done = false;
local cursor = "0";
local cnt = "2";
repeat
    local sr = redis.call("SCAN", cursor,"count",cnt);
    cursor = sr[1];
    for i, key in ipairs(sr[2]) do
        if redis.call("ttl", key) == -1 then
            table.insert(result,key)
        end;
    end;
    if cursor == "0" then
        done = true
    end;
until done;
return result;