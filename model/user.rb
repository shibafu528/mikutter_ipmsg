# coding: utf-8

module Plugin::IPMsg
  # Userモデル
  # IPMSGネットワークの参加者、メッセージの発信者を表す。
  class User < Retriever::Model
    include Retriever::Model::UserMixin

    field.string :name, required: true
    field.string :host, required: true
    field.string :group
    field.string :address

    def idname
      nil
    end

    def profile_image_url
      # IPMSGのユーザにはアイコンの概念がない
      Skin.get_path 'icon.png'
    end
  end
end