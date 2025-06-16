class CreateContactMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :contact_messages do |t|
      t.string :name
      t.string :email
      t.string :subject
      t.text :message
      t.boolean :reviewed, default: false, null: false

      t.timestamps
    end
  end
end
