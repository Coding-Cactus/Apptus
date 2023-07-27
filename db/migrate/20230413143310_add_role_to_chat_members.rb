# frozen_string_literal: true

class AddRoleToChatMembers < ActiveRecord::Migration[7.0]
  def change
    add_column :chat_members, :role, :integer, null: false, default: 0
  end
end
