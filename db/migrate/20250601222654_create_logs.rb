class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.references :user, foreign_key: true, null: true
      t.string :action, null: false
      t.text :description
      t.timestamps
    end

    add_index :logs, :action
  end
end
