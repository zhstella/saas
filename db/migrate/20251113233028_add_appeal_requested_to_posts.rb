class AddAppealRequestedToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :appeal_requested, :boolean, default: false, null: false
  end
end
