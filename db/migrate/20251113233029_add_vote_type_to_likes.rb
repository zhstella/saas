class AddVoteTypeToLikes < ActiveRecord::Migration[8.1]
  def change
    add_column :likes, :vote_type, :integer, default: 1, null: false
  end
end
