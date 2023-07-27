# frozen_string_literal: true

class AddContactNumberToUser < ActiveRecord::Migration[7.0]
  def down
    remove_index :users,  :contact_number
    remove_column :users, :contact_number
  end

  def up
    add_column :users, :contact_number, :string
    add_index :users,  :contact_number, unique: true

    numbers = []
    User.all.each do |user|
      number = Array.new(12) { ("0".."9").to_a.sample }.join while number.nil? || numbers.include?(number)

      numbers << number
      user.update(contact_number: number)
    end
  end
end
