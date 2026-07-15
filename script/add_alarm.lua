local item,rest = "",string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#"添加闹钟"+1)
if(rest == "")then
return "请输入参数"
end
local items = {}
repeat
item,rest = string.match(rest,"^([^%s]*)[%s]*(.-)$")
table.insert(items, item)
until(rest=="")
--添加闹钟 触发方式 x天后（仅一次） x时 x分
list = getUserConf(getDiceQQ(),"闹钟",{})
ulist = getUserConf(msg.uid,"alarms",{})
time = {}
for i = 2,#items do
    if(string.find(items[i],"天后") ~= nil)then
        time.day = tonumber(string.match(items[i], "%d+"))
    elseif(string.find(items[i],"时") ~= nil)then
        time.hour = tonumber(string.match(items[i], "%d+"))
    elseif(string.find(items[i],"分")~= nil)then
        time.min = tonumber(string.match(items[i], "%d+"))
    end
end
if(time.hour == nil or time.min == nil)then
    return "时间输入错误"
end
if(items[1] == "仅一次")then
    thisalarm = {
        state = -1,
        waitday = time.day or 0,
        hour = time.hour,
        min = time.min,
        gid = msg.gid,
        uid = msg.uid
    }
elseif(items[1] == "每天")then
    thisalarm = {
        state = 1,
        waitday = 0,
        hour = time.hour,
        min = time.min,
        gid = msg.gid,
        uid = msg.uid
    }
else
    if(string.find(items[1],"周") == nil)then
        return "触发类型错误"
    end
    rest = string.match(items[1],"%d+")
    if(rest == nil)then
        return "每周几请用阿拉伯数字并不带空格"
    end
    local weeks = {}
        rest = tonumber(rest)
    repeat
        item = rest%10
        rest = math.modf(rest/10)
        if(item>7 or item<1)then
            goto a
        end
        if(item < 7)then
            item = item + 1
        else
            item = 1
        end
        table.insert(weeks, item)
        ::a::
    until(rest == 0)
    Cweek = {7,1,2,3,4,5,6}
    for i = 1,#weeks do
        for j = 1,#weeks-1 do
            if(Cweek[weeks[j]] > Cweek[weeks[j+1]])then
                a = weeks[j]
                weeks[j] = weeks[j+1]
                weeks[j+1] = a
            end
        end
    end
    i = 1
    while(i<=#weeks-1)do
        if(weeks[i]==weeks[i+1])then
            table.remove(weeks,i)
            i = i - 1
        end
        i = i + 1
    end
    thisalarm = {
        state = 0,
        waitday = 0,
        hour = time.hour,
        min = time.min,
        wdays = weeks,
        gid = msg.gid,
        uid = msg.uid
    }
end
table.insert(ulist, thisalarm)
isin = false
for i = 1,#list do
    if(list[i] == msg.uid)then
        isin = true
        break
    end
end
if(not isin)then
    table.insert(list, msg.uid)
end
setUserConf(getDiceQQ(),"闹钟",list)
setUserConf(msg.uid,"alarms",ulist)
return "闹钟设置完成"