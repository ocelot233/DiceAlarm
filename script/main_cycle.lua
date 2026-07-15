function sendAlarm(alarm,i)
    usermsg = "你设置的的"..i.."闹钟到时间了哟"
    groupmsg = "[CQ:at,qq="..alarm.uid.."]你设置的的"..i.."闹钟到时间了哟"
    if(alarm.msg ~= nil)then
        usermsg = alarm.msg
        groupmsg = "[CQ:at,qq="..alarm.uid.."]"..alarm.msg
    end
    if(not alarm.gid)then
        sendMsg(usermsg, nil, alarm.uid)
    else
        sendMsg(groupmsg, alarm.gid)
    end
end
list = getUserConf(getDiceQQ(),"闹钟",{})
if(#list == 0)then
    return nil
end
now = os.date("*t")
i = 1
while(i <= #list)do
    ulist = getUserConf(list[i],"alarms",{})
    if(#ulist == 0)then
        table.remove(list,i)
        i = i - 1
        goto continue
    end
    j = 1
    while(j <= #ulist)do
        if(ulist[j].min == now.min and ulist[j].hour == now.hour)then
            if(ulist[j].waitday == 0)then--仅一次闹钟判定等待天数
                if(ulist[j].state == -1)then
                    sendAlarm(ulist[j],"仅响一次")
                    table.remove(ulist,j)
                    j = j - 1
                elseif(ulist[j].state == 1)then--每日闹钟
                    sendAlarm(ulist[j],j.."号")
                elseif(ulist[j].state == 0)then--每周几
                    for k = 1,#ulist[j].wdays do
                        if(ulist[j].wdays[k] == now.wday)then
                            sendAlarm(ulist[j],j.."号")
                            break
                        end
                    end
                end
            else
                ulist[j].waitday = ulist[j].waitday - 1
            end
        end
        j = j + 1
    end
    setUserConf(list[i],"alarms",ulist)
    ::continue::
    i = i + 1
end
setUserConf(getDiceQQ(),"闹钟",list)