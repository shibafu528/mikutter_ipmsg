# coding: utf-8
require 'socket'

module Plugin::IPMsg
  # Protocol Version
  VERSION      = 1
  # IPMSG Default Port (TCP/UDP)
  DEFAULT_PORT = 2425

  class IPMsg
    attr_accessor :name, :host
    attr_reader :port, :socket

    def initialize(port = DEFAULT_PORT, options = {})
      @name = options[:name] || ENV['USER'] || ENV['USERNAME'] || 'Unknown_User'
      @host = options[:host] || `hostname`.chomp || 'Unknown_Host'
      @port = port
    end

    def connect
      @socket = UDPSocket.open
      @socket.bind('0.0.0.0', @port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
      @receiver = Thread.new do
        loop do
          receive = @socket.recv(65535).chomp
          p receive

          # TODO: さーてどうすっかぁーーｗｗｗｗ
          message = receive.split(':')
        end
      end

      entry
      @connected = true

      Plugin.call :ipmsg_connected, self
    end

    def disconnect
      exit

      @receiver.exit
      @socket.close
      @connected = false

      Plugin.call :ipmsg_disconnected, self
    end

    def connected?
      @connected
    end

    def to_s
      "#{@name}@#{@host}:#{@port}"
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

  end
end

require_relative 'mnemonic'
require_relative 'command'