# frozen_string_literal: true

class DropChatAdministrators < ActiveRecord::Migration[7.0]
  def change
    drop_table :chat_administrators
  end
end
