# frozen_string_literal: true

class AddOwnerIdToChats < ActiveRecord::Migration[7.0]
  def change
    add_column :chats, :owner_id, :integer, foreign_key: true, default: User.find_by(role: :system).id
  end
end
