# frozen_string_literal: true

class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.string :name
      t.string :colour
      t.string :pfp

      t.timestamps
    end
  end
end
