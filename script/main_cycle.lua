--传入闹钟表，负责发送闹钟
function sendAlarm(alarm,i)
    --私聊前缀
    private_prefix = ""
    --群聊前缀
    group_prefix = "自定义闹钟："
    --可自由更改
    usermsg = "你设置的的"..i.."闹钟到时间了哟"
    groupmsg = "[CQ:at,qq="..alarm.uid.."]你设置的的"..i.."闹钟到时间了哟"
    if(alarm.msg ~= nil)then
        if(alarm.msgprefix)then
            usermsg = private_prefix..alarm.msg
            groupmsg = group_prefix..alarm.msg
        else
            usermsg = alarm.msg
            groupmsg = alarm.msg
        end
    end
    --主提醒（原提醒）
    if(not alarm.gid)then
        sendMsg(usermsg, nil, alarm.uid)
    else
        sendMsg(groupmsg, alarm.gid)
    end
    --附加提醒列表
    if alarm.extendgid ~= nil then
        for i = 1,#alarm.extendgid do
            sendMsg(groupmsg, alarm.extendgid[i])
        end
    end
end

list = getUserConf(getDiceQQ(),"闹钟",{})
if(#list == 0)then
    return nil
end
now = os.date("*t")
i = 1
--遍历用户表
while(i <= #list)do
    ulist = getUserConf(list[i],"alarms",{})
    --用户闹钟表为空则移除该用户
    if(#ulist == 0)then
        table.remove(list,i)
        i = i - 1
        goto continue
    end
    j = 1
    --遍历用户的闹钟表
    while(j <= #ulist)do
        if(ulist[j].min == now.min and ulist[j].hour == now.hour)then
            --仅一次闹钟判定等待天数
            if(ulist[j].waitday == 0)then
                if(ulist[j].state == -1)then
                    sendAlarm(ulist[j],"仅响一次")
                    --响完删除
                    table.remove(ulist,j)
                    j = j - 1
                --每日闹钟
                elseif(ulist[j].state == 1)then
                    sendAlarm(ulist[j],j.."号")
                --每周几
                elseif(ulist[j].state == 0)then
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