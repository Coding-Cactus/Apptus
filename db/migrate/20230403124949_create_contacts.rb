class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.integer :creator_id
      t.integer :target_id
      t.string :status

      t.timestamps
    end
  end
end
