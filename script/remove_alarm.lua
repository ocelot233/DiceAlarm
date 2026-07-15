num = tonumber(string.match(msg.fromMsg,"%d+",#"删除闹钟"+1))
ulist = getUserConf(msg.uid,"alarms",{})
if(num == nil)then
    return"{alarm_delete_no_para}"
end
if(num <= 0 or num > #ulist)then
    return"{alarm_delete_id_not_fd}"
end
table.remove(ulist,num)
setUserConf(msg.uid,"alarms",ulist)
return "{alarm_delete_success}"