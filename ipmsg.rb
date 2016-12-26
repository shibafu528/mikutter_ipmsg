# coding: utf-8

require_relative 'core'

Plugin.create :ipmsg do
  @ipmsg = Plugin::IPMsg::IPMsg.new

  on_boot {
    @ipmsg.connect
  }

  at_exit {
    @ipmsg.disconnect if @ipmsg.connected?
  }

=begin
  on_ipmsg_connected { |ipmsg|
    puts "[IPMSG] #{ipmsg.to_s} : Connected"
  }

  on_ipmsg_disconnected { |ipmsg|
    puts "[IPMSG] #{ipmsg.to_s} : Disconnected"
  }
=end

end
