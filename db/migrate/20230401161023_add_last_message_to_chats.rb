# frozen_string_literal: true

class AddLastMessageToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :last_message_id, :integer
  end
end
