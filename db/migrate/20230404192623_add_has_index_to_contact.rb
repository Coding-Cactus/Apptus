# frozen_string_literal: true

class AddHasIndexToContact < ActiveRecord::Migration[7.0]
  def change
    add_index :contacts, :target_id,  using: "hash"
    add_index :contacts, :creator_id, using: "hash"
  end
end
