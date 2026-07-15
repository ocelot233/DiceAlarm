ulist = getUserConf(msg.uid,"alarms",{})
alarms = {}
if(#ulist == 0)then
    return "{alarm_list_empty}"
end
function formatgid(gid)
    if(gid == nil)then
        return"私聊"
    else
        return"群"..gid
    end
end
page = tonumber(msg.suffix:match("^[%s]*(%d+)[%s]*$")) or 1
enpage = math.ceil(#ulist / 5)

j = (page - 1) * 5 + 1
pend = page * 5

if #ulist <= 5 then
    j = 1
    pend = #ulist
end

if pend > #ulist then
    pend = #ulist
end

while(j <= pend)do
    if ulist[j].extendgid ~= nil then
        extendgid = ""
        for i = 1,#ulist[j].extendgid do
            if i == 1 then
                extendgid = extendgid .. "附加提醒位置：" .. formatgid(ulist[j].extendgid[i])
            else
                extendgid = extendgid .. "," .. formatgid(ulist[j].extendgid[i])
            end
        end
    end
    if extendgid == "" then extendgid = nil end
    if(ulist[j].msgprefix)then
        prefix = "(有前缀的)"
    else
        prefix = ""
    end
    if(ulist[j].state == -1)then
        alarm = {
            "编号#"..j..":",
            "仅响一次",
            ulist[j].waitday.."天后"..ulist[j].hour.."时"..ulist[j].min.."分",
            "主提醒位置："..formatgid(ulist[j].gid),
            extendgid
        }
        if(ulist[j].msg ~= nil)then
            
            table.insert(alarm,"提醒词："..prefix..ulist[j].msg)
        end
        table.insert(alarms, table.concat (alarm, "\n"))
    elseif(ulist[j].state == 1)then
        alarm = {
            "编号#"..j..":",
            "每日",
            ulist[j].hour.."时"..ulist[j].min.."分",
            "主提醒位置："..formatgid(ulist[j].gid),
            extendgid
        }
        if(ulist[j].msg ~= nil)then
            table.insert(alarm,"提醒词："..prefix..ulist[j].msg)
        end
        table.insert(alarms, table.concat (alarm, "\n"))
    elseif(ulist[j].state == 0)then
        weeks = ""
        for k = 1,#ulist[j].wdays do
            week = {"日","一","二","三","四","五","六"}
            weeks = weeks.." "..week[ulist[j].wdays[k]]
        end
        alarm = {
            "编号#"..j..":",
            "每周"..weeks,
            ulist[j].hour.."时"..ulist[j].min.."分",
            "主提醒位置："..formatgid(ulist[j].gid),
            extendgid
        }
        if(ulist[j].msg ~= nil)then
            table.insert(alarm,"提醒词："..prefix..ulist[j].msg)
        end
        table.insert(alarms, table.concat (alarm, "\n"))
    end
    j=j+1
end
table.insert(alarms, "第"..page.."页，共"..enpage.."页")
return table.concat (alarms, "\n")