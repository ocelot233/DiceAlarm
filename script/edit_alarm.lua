--是否允许自定义提醒词,可选值：true/false
--用户可以设置骰娘发言内容，慎重考虑是否启用
enable_custom_message = false
--以下为实现代码
local item,rest = "",string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#"修改闹钟"+1)
if(rest == "")then
return "请输入参数"
end
local items = {}
repeat
item,rest = string.match(rest,"^([^%s]*)[%s]*(.-)$")
table.insert(items, item)
until(rest=="")
items[1] = tonumber(items[1])
ulist = getUserConf(msg.uid,"alarms",{})
if(type(items[1]) ~= "number")then
    return "请输入编号"
end
if(items[1] <= 0 or items[1] > #ulist)then
    return "没有该编号的闹钟"
end
if(items[2] == "提醒位置")then
    if(items[3] == "私聊")then
        ulist[items[1]].gid = nil
    elseif(string.find(items[3],"群") ~= nil)then
        ulist[items[1]].gid = tonumber(string.match(items[3],"%d+",#"群"+1))
    end
elseif(items[2] == "提醒词")then
    if(not enable_custom_message)then
        return "暂时无法修改提醒词"
    end
    if(items[3] == nil)then
        ulist[items[1]].msg = nil
        return "已恢复默认提醒词"
    end
    ulist[items[1]].msg = items[3]
elseif(items[2] == "时间")then
    time = {}
    for i = 3,#items do
        if(string.find(items[i],"天后") ~= nil)then
            time.day = tonumber(string.match(items[i], "%d+"))
        elseif(string.find(items[i],"时") ~= nil)then
            time.hour = tonumber(string.match(items[i], "%d+"))
        elseif(string.find(items[i],"分")~= nil)then
            time.min = tonumber(string.match(items[i], "%d+"))
        end
    end
    if(ulist[items[1]].state == -1)then
        ulist[items[1]].waitday = time.day or 0
    end
    ulist[items[1]].hour = time.hour
    ulist[items[1]].min = time.min
elseif(items[2] == "周")then
    if(ulist[items[1]].state ~= 0)then
        return "该闹钟类型不可修改触发日"
    end
    rest = items[3]
    if(rest == nil)then
        return "每周几请用阿拉伯数字"
    end
    local weeks = {}
    rest = tonumber(rest)
    repeat
        item = rest%10
        rest = math.modf(rest/10)
        if(item>7 or item<1)then
            goto continue
        end
        if(item < 7)then
            item = item + 1
        else
            item = 1
        end
        table.insert(weeks, item)
        ::continue::
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
    ulist[items[1]].wdays = weeks
else
    return "参数错误"
end
setUserConf(msg.uid,"alarms",ulist)
return "修改完成"