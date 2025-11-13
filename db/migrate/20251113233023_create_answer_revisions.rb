class CreateAnswerRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :answer_revisions do |t|
      t.references :answer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
