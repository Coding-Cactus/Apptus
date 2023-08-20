class RemovePfpFromChat < ActiveRecord::Migration[7.0]
  def up
    remove_column :chats, :pfp
  end

  def down
    add_column :chats, :pfp, :string
  end
end
