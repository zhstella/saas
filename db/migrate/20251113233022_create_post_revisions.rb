class CreatePostRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :post_revisions do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
