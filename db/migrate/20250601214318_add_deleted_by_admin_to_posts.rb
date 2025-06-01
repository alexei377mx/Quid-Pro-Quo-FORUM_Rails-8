class AddDeletedByAdminToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :deleted_by_admin, :boolean, default: false, null: false
  end
end
