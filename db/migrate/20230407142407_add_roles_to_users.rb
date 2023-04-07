class AddRolesToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :role, :integer, default: 0

    User.all.each { |u| u.update(role: :basic) }

    User.create(name: 'Apptus System', role: :system)
  end

  def down
    User.find_by(role: :system)&.destroy

    remove_column :users, :role
  end
end
