# frozen_string_literal: true

class RemoveLastMessageFromChats < ActiveRecord::Migration[7.0]
  def change
    remove_column :chats, :last_message_id, :integer
  end
end
