local result = {};
local done = true;
local cursor = "0";
local cnt = "1";
local shellcursor = "0";

repeat
    local sr = redis.call("SCAN", cursor,"count",cnt);
    shellcursor = sr[1];
    table.insert(result,shellcursor);
    for i, key in ipairs(sr[2]) do
        if redis.call("ttl", key) == -1 then
            table.insert(result,key)
        end;
    end;
until done;
return result;

-- 30000000
-- 60 min
-- 500000

-- 0.011547
-- x5
-- 0.057735

-- 1s 17条数据
-- 1min 1020