class CreateCommentReactions < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true

      t.timestamps
    end

    add_index :comment_reactions, [ :user_id, :comment_id ], unique: true
  end
end
