# coding: utf-8
require 'socket'

module Plugin::IPMsg
  # Protocol Version
  VERSION      = 1
  # IPMSG Default Port (TCP/UDP)
  DEFAULT_PORT = 2425

  class IPMsg
    attr_accessor :name, :group, :host
    attr_reader :port, :socket

    def initialize(options = {})
      @name = options[:name] || ENV['USER'] || ENV['USERNAME'] || 'Unknown_User'
      @group = options[:group] || ''
      @host = options[:host] || `hostname`.chomp || 'Unknown_Host'
      @port = options[:port] || DEFAULT_PORT
    end

    def connect
      @socket = UDPSocket.open
      @socket.bind('0.0.0.0', @port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, 1)
      @receiver = Thread.new do
        loop do
          receive = @socket.recv(65535).chomp
          notice receive

          # VERSION:PACKET_NO:NAME:HOST:COMMAND_NO の最低5要素はあるはず
          message = receive.split(':')
          if message.length >= 5
            Plugin.call :ipmsg_dump, receive
          end
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

  end
end

require_relative 'mnemonic'
require_relative 'command'