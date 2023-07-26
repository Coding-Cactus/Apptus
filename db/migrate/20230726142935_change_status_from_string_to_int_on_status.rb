class ChangeStatusFromStringToIntOnStatus < ActiveRecord::Migration[7.0]
  def up
    change_column :statuses, :status, :integer, using: 'status::integer', default: 0
  end

  def down
    change_column :statuses, :status, :string
  end
end
