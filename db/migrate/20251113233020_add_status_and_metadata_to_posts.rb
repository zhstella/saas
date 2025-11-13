class AddStatusAndMetadataToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :status, :string, null: false, default: 'open'
    add_column :posts, :school, :string
    add_column :posts, :course_code, :string

    add_index :posts, :status
    add_index :posts, :school
    add_index :posts, :course_code
  end
end
