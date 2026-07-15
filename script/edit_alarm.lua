
--以下设置可能允许用户完全或部分设置骰娘的发言内容，类似于自定义回复
--可能导致骰娘 发送不可预料的内容 或引起骰娘间互相触发指令。慎重考虑是否修改

--是否允许用户自定义提醒词,可选值：true/false
enable_custom_message = false

--允许自定义提醒词的信任级别,1代表trust ≥ 1的用户（普通用户为0，请自行查看骰主手册中用户授信（.user trust)的内容）
--若允许，强烈建议给普通用户受限的固定前缀的编辑
custom_message_edit_trust_value = {
    suffix = 0,   -- 使用固定前缀,仅允许编辑后缀(固定前缀可在 alarm/script/main_cycle.lua 中自定义)
    full = 2,     -- 完全编辑
    beyond = 5   -- （特权）可越过开关编辑
}

--以下为实现代码
local item,rest = "",string.match(msg.fromMsg,"^[%s]*(.-)[%s]*$",#"修改闹钟"+1)
if(rest == "")then
return "{alarm_para_empty}"
end
local items = {}
repeat
item,rest = string.match(rest,"^([^%s]*)[%s]*(.-)$")
table.insert(items, item)
until(rest=="")
ulist = getUserConf(msg.uid,"alarms",{})

function errPrompt(item,num,str)
    fstr = "{alarm_edit_err_head}[修改闹钟 "
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
if(type(tonumber(items[1])) ~= "number")then
    return errPrompt(items,1,"{alarm_id_not_num}")
end
items[1] = tonumber(items[1])
if(items[1] <= 0 or items[1] > #ulist)then
    msg.anum = #ulist
    return errPrompt(items,1,"{alarm_id_not_found}")
end
--改为递归向下解析，以支持多参数解析
if(items[2] == nil)then
    return errPrompt(items,-1,"{alarm_para_empty_err}")
elseif(items[2] == "更改提醒位置")then
    ulist[items[1]].gid = msg.gid
    if ulist[items[1]].extendgid ~= nil then
        local i=1
        while(i<=#ulist[items[1]].extendgid) do
            if(ulist[items[1]].extendgid[i] == msg.gid)then
                table.remove(ulist[items[1]].extendgid,i)
                i=i-1
            end
            i = i+1
        end
    end
elseif(items[2] == "增加提醒位置")then
    if ulist[items[1]].gid == msg.gid then
        ulist[items[1]].gid = nil
    end
    if ulist[items[1]].extendgid ~= nil then
        table.insert(ulist[items[1]].extendgid, msg.gid)
    else
        ulist[items[1]].extendgid = {}
        table.insert(ulist[items[1]].extendgid, msg.gid)
    end
elseif(items[2] == "删除提醒位置")then
    str = "{alarm_del_cptn_empty}"
    if items[3] == nil then
        poz = msg.gid
    else
        poz = tonumber(string.match(items[3],"%d+")) or msg.gid
    end
    if ulist[items[1]].gid == poz then
        ulist[items[1]].gid = nil
        str = "{alarm_del_cptn_success}"
    end
    if ulist[items[1]].extendgid ~= nil then
        local i=1
        while(i<=#ulist[items[1]].extendgid) do
            if(ulist[items[1]].extendgid[i] == poz)then
                table.remove(ulist[items[1]].extendgid,i)
                i=i-1
                str = "{alarm_del_cptn2_success}"
            end
            i = i+1
        end
    end
elseif(items[2] == "提醒词")then
    --判断是否开启编辑，以及是否豁免编辑
    ulist[items[1]].msgprefix=true
    if(not enable_custom_message and getUserConf(msg.fromQQ,"trust",0) < custom_message_edit_trust_value.beyond)then
        return "{alarm_custom_disable}"
    --判断权限可否完全编辑
    elseif(getUserConf(msg.fromQQ,"trust",0) >= custom_message_edit_trust_value.full)then
        ulist[items[1]].msgprefix=false
    --判断权限可否编辑后缀
    elseif(getUserConf(msg.fromQQ,"trust",0) >= custom_message_edit_trust_value.suffix)then
        ulist[items[1]].msgprefix=true
    else
        return "{alarm_custom_no_perm}"
    end
    if(items[3] == nil)then
        ulist[items[1]].msg = nil
        str = "{alarm_custom_redefault}"
    end
    ulist[items[1]].msg = items[3]
elseif(items[2] == "时间")then
    time = {}
    for i = 3,#items do
        if(string.find(items[i],"天后") ~= nil)then
            time.day = tonumber(string.match(items[i], "%d+"))
            if not time.day then
                return errPrompt(items,i,"{alarm_check_day_err}")
            end
        elseif(string.find(items[i],"时") ~= nil)then
            time.hour = tonumber(string.match(items[i], "%d+"))
            if not time.hour or time.hour < 0 or time.hour > 23 then
                return errPrompt(items,i,"{alarm_check_hour_err}")
            end
        elseif(string.find(items[i],"分")~= nil)then
            time.min = tonumber(string.match(items[i], "%d+"))
            if not time.min or time.min < 0 or time.min > 59 then
                return errPrompt(items,i,"{alarm_check_min_err}")
            end
        end
    end
    if(ulist[items[1]].state == -1)then
        ulist[items[1]].waitday = time.day or 0
    end
    ulist[items[1]].hour = time.hour or ulist[items[1]].hour
    ulist[items[1]].min = time.min or ulist[items[1]].min
elseif(string.find(items[2],"周"))then
    if(ulist[items[1]].state ~= 0)then
        return "{alarm_para_type_incptb}"
    end
    rest = string.match(items[3],"%d+") or string.match(items[2],"%d+")
    if(rest == nil)then
        return errPrompt(items,-1,"{alarm_check_week_err}")
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
    return errPrompt(items,2,"未知的参数")
end
setUserConf(msg.uid,"alarms",ulist)
return str or "{alarm_edit_success}"