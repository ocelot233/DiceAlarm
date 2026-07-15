ulist = getUserConf(msg.uid,"alarms",{})
alarms = {}
if(#ulist == 0)then
    return "你还没有闹钟呢，快去设置一个吧"
end
j=1
while(j <= #ulist)do
    if(ulist[j].gid == nil)then
        where = "私聊"
    else
        where = "群"..ulist[j].gid
    end
    if(ulist[j].state == -1)then
        alarm = {
            "编号#"..j..":",
            "仅响一次",
            ulist[j].waitday.."天后"..ulist[j].hour.."时"..ulist[j].min.."分在"..where.."提醒"
        }
        table.insert(alarms, table.concat (alarm, "\n"))
    elseif(ulist[j].state == 1)then
        alarm = {
            "编号#"..j..":",
            "每日",
            ulist[j].hour.."时"..ulist[j].min.."分在"..where.."提醒"
        }
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
            ulist[j].hour.."时"..ulist[j].min.."分在"..where.."提醒"
        }
        table.insert(alarms, table.concat (alarm, "\n"))
    end
    j=j+1
end
return table.concat (alarms, "\n")