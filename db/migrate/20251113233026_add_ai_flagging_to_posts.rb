class AddAiFlaggingToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :ai_flagged, :boolean, default: false, null: false
    add_column :posts, :screened_at, :datetime

    add_index :posts, :ai_flagged
  end
end
