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

  defactivity :ipmsg, 'IPメッセンジャー'

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
    activity :ipmsg, "IPメッセンジャーのログイン名は「#{ipmsg.to_s}」です。"
  }

  on_ipmsg_disconnected {
    activity :ipmsg, 'IPメッセンジャーを切断しました。'
  }

  filter_ipmsg_receive { |ipmsg, msg_parts, inet_addr|
    # TODO: ヤケクソすぎるのでなんとかしたい（msg_partsをcall元でもうちょっといい感じに加工してから送り出したほうが見やすそう）

    command_no = msg_parts[Plugin::IPMsg::Part::COMMAND_NO].to_i
    command = command_no & Plugin::IPMsg::COMMAND_MASK
    option = command_no & Plugin::IPMsg::OPTION_MASK

    notice "command=#{command}, option=#{option}"

    # 応答を返さないといけないメッセージと、非メッセージについて処理を行う
    case command
      when Plugin::IPMsg::Mnemonic::BR_ENTRY
        ipmsg.ansentry(inet_addr[3], option & Plugin::IPMsg::Mnemonic::CAPUTF8OPT == Plugin::IPMsg::Mnemonic::CAPUTF8OPT)
        activity :ipmsg, "#{msg_parts[Plugin::IPMsg::Part::USER].encode('utf-8')} さんがオンラインです。"
        Filter.cancel!
      when Plugin::IPMsg::Mnemonic::BR_EXIT
        activity :ipmsg, "#{msg_parts[Plugin::IPMsg::Part::USER].encode('utf-8')} さんがオフラインになりました。"
        Filter.cancel!
      when Plugin::IPMsg::Mnemonic::ANSENTRY
        activity :ipmsg, "#{msg_parts[Plugin::IPMsg::Part::USER]} さんがオンラインです。"
        Filter.cancel!
      when Plugin::IPMsg::Mnemonic::SENDMSG
        ipmsg.recv(inet_addr[3], msg_parts[Plugin::IPMsg::Part::PACKET_NO]) if option & Plugin::IPMsg::Mnemonic::SENDCHECKOPT == Plugin::IPMsg::Mnemonic::SENDCHECKOPT
        msg = Plugin::IPMsg::Message.new(text: msg_parts[Plugin::IPMsg::Part::EXTRAS],
                                         created: Time.now,
                                         user: Plugin::IPMsg::User.new(name: msg_parts[Plugin::IPMsg::Part::USER],
                                                                       host: msg_parts[Plugin::IPMsg::Part::HOST]))
      when Plugin::IPMsg::Mnemonic::GETINFO
        ipmsg.sendinfo(inet_addr[3])
        Filter.cancel!
    end

    [ipmsg, msg || msg_parts, inet_addr]
  }

  on_ipmsg_receive { |ipmsg, msg|
    notice "#{ipmsg.to_s} #{msg}"
    Plugin.call :extract_receive_message, :ipmsg, [msg] if msg.is_a? Plugin::IPMsg::Message
  }

end
