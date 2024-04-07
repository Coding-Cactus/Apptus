class AddIsUsingGravatarToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :is_using_gravatar, :boolean, default: false
  end
end
