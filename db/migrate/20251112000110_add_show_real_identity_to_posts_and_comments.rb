class AddShowRealIdentityToPostsAndComments < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :show_real_identity, :boolean, null: false, default: false
    add_column :comments, :show_real_identity, :boolean, null: false, default: false
  end
end
