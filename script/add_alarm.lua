local item,rest = "",string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#"添加闹钟"+1)
if(rest == "")then
return "{alarm_para_empty}"
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
errp = ""

function errPrompt(item,num,str)
    fstr = "{alarm_add_err_head}[添加闹钟 "
    if(num == -1)then
        for i=1,#item do
            fstr = fstr..item[i].." "
        end
        return fstr.."<- "..str
    else
        for i=1,num-1 do
            fstr = fstr..item[i].." "
        end
        return fstr.." ->"..item[num].."<- ]"..str
    end

end

--items[] be like:{仅一次/每天/周W[1-7],(d天后),hh时,mm分}
for i = 2,#items do
    if(string.find(items[i],"天后") ~= nil)then
        time.day = tonumber(string.match(items[i], "%d+"))
        if not time.day then
            errp = errPrompt(items,i,"{alarm_check_day_err}")
        end
    elseif(string.find(items[i],"时") ~= nil)then
        time.hour = tonumber(string.match(items[i], "%d+"))
        if not time.hour or time.hour < 0 or time.hour > 23 then
            errp = errPrompt(items,i,"{alarm_check_hour_err}")
            time.hour = 0
        end
    elseif(string.find(items[i],"分")~= nil)then
        time.min = tonumber(string.match(items[i], "%d+"))
        if not time.min or time.min < 0 or time.min > 59 then
            errp = errPrompt(items,i,"{alarm_check_min_err}")
            time.min = 0
        end
    end
end
if(time.hour == nil)then
    errp = errPrompt(items,-1,"{alarm_check_hour_not_found}")
end
if(items[1] == "仅一次")then
    thisalarm = {
        state = -1,
        waitday = time.day or 0,
        hour = time.hour,
        min = time.min or 0,
        gid = msg.gid,
        uid = msg.uid
    }
elseif(items[1] == "每天" or items[1] == "每日")then
    thisalarm = {
        state = 1,
        waitday = 0,
        hour = time.hour,
        min = time.min or 0,
        gid = msg.gid,
        uid = msg.uid
    }
else
    if(string.find(items[1],"周") == nil)then
        return errPrompt(items,1,"{alarm_check_type_not_found}")
    end
    rest = string.match(items[1],"%d+")
    if(rest == nil)then
        return errPrompt(items,1,"{alarm_check_week_err}")
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
    thisalarm = {
        state = 0,
        waitday = 0,
        hour = time.hour,
        min = time.min or 0,
        wdays = weeks,
        gid = msg.gid,
        uid = msg.uid
    }
end
if #errp > 0 then
    return errp
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
return "{alarm_add_success}"