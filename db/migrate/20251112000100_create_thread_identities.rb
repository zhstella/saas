class CreateThreadIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :thread_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true
      t.string :pseudonym, null: false

      t.timestamps
    end

    add_index :thread_identities, [:user_id, :post_id], unique: true
  end
end
