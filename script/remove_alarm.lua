num = tonumber(string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#"删除闹钟"+1))
ulist = getUserConf(msg.uid,"alarms",{})
if(num == nil)then
    return"请输入编号"
end
if(num <= 0 or num > #ulist)then
    return"没有该编号的闹钟"
end
table.remove(ulist,num)
setUserConf(msg.uid,"alarms",ulist)
return "操作完成"