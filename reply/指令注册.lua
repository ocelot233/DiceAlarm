msg_reply.alarm_add = {
  keyword = {
    prefix = {"添加闹钟","新建闹钟"}
  },
  limit = {
    cd = { user = 3 },
  },
  echo = {
    lua = "add_alarm"
  }
}
msg_reply.alarm_del = {
  keyword = {
    prefix = "删除闹钟"
  },
  limit = {
    cd = { user = 3 },
  },
  echo = {
    lua = "remove_alarm"
  }
}
msg_reply.alarm_show = {
  keyword = {
    prefix = "我的闹钟"
  },
  limit = {
    cd = { user = 3 },
  },
  echo = {
    lua = "show_alarm"
  }
}