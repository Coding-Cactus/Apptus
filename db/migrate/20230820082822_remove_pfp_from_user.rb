# frozen_string_literal: true

class RemovePfpFromUser < ActiveRecord::Migration[7.0]
  def up
    remove_column :users, :pfp
  end

  def down
    add_column :users, :pfp, :string
  end
end
