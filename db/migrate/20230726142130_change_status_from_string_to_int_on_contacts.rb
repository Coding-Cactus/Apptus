# frozen_string_literal: true

class ChangeStatusFromStringToIntOnContacts < ActiveRecord::Migration[7.0]
  def up
    change_column :contacts, :status, :integer, using: "status::integer", default: 0
  end

  def down
    change_column :contacts, :status, :string
  end
end
