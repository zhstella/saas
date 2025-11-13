class CreateAnswerComments < ActiveRecord::Migration[8.1]
  def change
    create_table :answer_comments do |t|
      t.text :body, null: false
      t.references :answer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
