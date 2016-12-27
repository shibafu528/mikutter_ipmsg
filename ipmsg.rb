# coding: utf-8

require_relative 'core'

Plugin.create :ipmsg do
  UserConfig[:ipmsg_name] ||= ENV['USER'] || ENV['USERNAME']
  UserConfig[:ipmsg_port] ||= Plugin::IPMsg::DEFAULT_PORT

  @ipmsg = Plugin::IPMsg::IPMsg.new(name: UserConfig[:ipmsg_name], group: UserConfig[:ipmsg_group], port: UserConfig[:ipmsg_port])

  on_boot {
    @ipmsg.connect
  }

  at_exit {
    @ipmsg.disconnect if @ipmsg.connected?
  }

  filter_extract_datasources { |ds|
    ds[:ipmsg] = 'IPメッセンジャー'
    [ds]
  }

  settings('IPメッセンジャー') {
    settings('ユーザー情報') {
      input 'ユーザー名', :ipmsg_name
      input 'グループ名', :ipmsg_group
    }
    settings('通信設定') {
      adjustment 'ポート番号 (デフォルト: 2425)', :ipmsg_port, 0, 65535
    }
  }

  on_ipmsg_connected { |ipmsg|
    activity :system, "IPメッセンジャーのログイン名は「#{ipmsg.to_s}」です。"
  }

  on_ipmsg_disconnected {
    activity :system, 'IPメッセンジャーを切断しました。'
  }

  on_ipmsg_receive {
  }

end
