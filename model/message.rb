# coding: utf-8

module Plugin::IPMsg
  # Messageモデル
  # IPMSGプロトコルで受信したメッセージを表す。
  class Message < Retriever::Model
    include Retriever::Model::MessageMixin

    register :ipmsg_message,
             name: 'IPMSG Message'

    field.has    :user, Plugin::IPMsg::User, required: true
    field.string :text, required: true
    field.time   :created

    def to_show
      @to_show ||= self[:text]
    end
  end
end