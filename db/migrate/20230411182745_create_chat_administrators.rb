class CreateChatAdministrators < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_administrators do |t|
      t.references :chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
