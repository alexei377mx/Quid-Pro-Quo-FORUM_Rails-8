class CreateRadios < ActiveRecord::Migration[8.0]
  def change
    create_table :radios do |t|
      t.string :title
      t.string :stream_url

      t.timestamps
    end
  end
end
