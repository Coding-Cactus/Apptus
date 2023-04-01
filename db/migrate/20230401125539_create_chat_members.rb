class CreateChatMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat, null: false, foreign_key: true

      t.timestamps
    end
  end
end
