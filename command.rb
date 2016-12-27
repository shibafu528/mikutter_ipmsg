# coding: utf-8

module Plugin::IPMsg::Command

  def command(command_number)
    Query.new(command_number, self)
  end

  def entry
    command(Plugin::IPMsg::Mnemonic::BR_ENTRY).caputf8opt.broadcast
  end

  def exit
    command(Plugin::IPMsg::Mnemonic::BR_EXIT).broadcast
  end

  def send(to, text)
    command(Plugin::IPMsg::Mnemonic::SENDMSG).utf8opt.extra(text).send(to)
  end

  class Query
    MAX_RAND = (1 << 30) - 1

    def initialize(command_no, ipmsg)
      @command_no = command_no
      @ipmsg = ipmsg
      @packet_no = Random.rand(MAX_RAND)
      @options = []
      @extras = []
    end

    def option(option)
      @options << option
      self
    end

    def extra(extra)
      @extras << extra
      self
    end

    def force_cp932?
      [Plugin::IPMsg::Mnemonic::BR_ENTRY,
       Plugin::IPMsg::Mnemonic::BR_EXIT,
       Plugin::IPMsg::Mnemonic::BR_ABSENCE].include? @command_no
    end

    def to_command
      command_hex = @command_no
      command_hex |= @options.inject(:|) unless @options.empty?

      command = [Plugin::IPMsg::VERSION, @packet_no, @ipmsg.name, @ipmsg.host, command_hex, *@extras].join(':')
      command.encode('cp932') if force_cp932?
    end

    def send(to)
      @ipmsg.socket.send(to_command, 0, to, @ipmsg.port)
    end

    def broadcast
      @ipmsg.socket.send(to_command, 0, '255.255.255.255', @ipmsg.port)
    end

    def self.defopt(name, option)
      define_method(name) { self.option(option) }
    end

    defopt :absenseopt,       Plugin::IPMsg::Mnemonic::ABSENCEOPT
    defopt :serveropt,        Plugin::IPMsg::Mnemonic::SERVEROPT
    defopt :dialupopt,        Plugin::IPMsg::Mnemonic::DIALUPOPT
    defopt :fileattachopt,    Plugin::IPMsg::Mnemonic::FILEATTACHOPT
    defopt :encryptopt,       Plugin::IPMsg::Mnemonic::ENCRYPTOPT
    defopt :utf8opt,          Plugin::IPMsg::Mnemonic::UTF8OPT
    defopt :caputf8opt,       Plugin::IPMsg::Mnemonic::CAPUTF8OPT
    defopt :encextmsgopt,     Plugin::IPMsg::Mnemonic::ENCEXTMSGOPT
    defopt :clipboardopt,     Plugin::IPMsg::Mnemonic::CLIPBOARDOPT
    defopt :capfileenc_obslt, Plugin::IPMsg::Mnemonic::CAPFILEENC_OBSLT
    defopt :capfileencopt,    Plugin::IPMsg::Mnemonic::CAPFILEENCOPT

    defopt :sendcheckopt, Plugin::IPMsg::Mnemonic::SENDCHECKOPT
    defopt :secretopt,    Plugin::IPMsg::Mnemonic::SECRETOPT
    defopt :broadcastopt, Plugin::IPMsg::Mnemonic::BROADCASTOPT
    defopt :multicastopt, Plugin::IPMsg::Mnemonic::MULTICASTOPT
    defopt :autoretopt,   Plugin::IPMsg::Mnemonic::AUTORETOPT
    defopt :retryopt,     Plugin::IPMsg::Mnemonic::RETRYOPT
    defopt :passwordopt,  Plugin::IPMsg::Mnemonic::PASSWORDOPT
    defopt :nologopt,     Plugin::IPMsg::Mnemonic::NOLOGOPT
    defopt :noaddlistopt, Plugin::IPMsg::Mnemonic::NOADDLISTOPT
    defopt :readcheckopt, Plugin::IPMsg::Mnemonic::READCHECKOPT
    defopt :secretexopt,  Plugin::IPMsg::Mnemonic::SECRETEXOPT
  end
end

class Plugin::IPMsg::IPMsg; include Plugin::IPMsg::Command; end