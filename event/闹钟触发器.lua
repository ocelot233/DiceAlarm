event.alarm_main_crcle = {	
    title = "闹钟时间判定",
    trigger = {
		cycle = {
			second = 60,--每60秒判定一次  不得高于60秒(会忽略掉某些闹钟)，时间越短闹钟越准，但使用的硬件资源也越多
			}
		},
    action = {
        lua = "main_cycle"
    }
}