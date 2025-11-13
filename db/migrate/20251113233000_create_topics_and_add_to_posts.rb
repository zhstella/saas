class CreateTopicsAndAddToPosts < ActiveRecord::Migration[8.1]
  class Topic < ApplicationRecord; end

  def up
    create_table :topics do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :topics, :name, unique: true

    Topic.reset_column_information
    general = Topic.find_or_create_by!(name: 'General')

    add_reference :posts, :topic, null: false, foreign_key: true, default: general.id
    change_column_default :posts, :topic_id, from: general.id, to: nil
  end

  def down
    remove_reference :posts, :topic, foreign_key: true
    drop_table :topics
  end
end
