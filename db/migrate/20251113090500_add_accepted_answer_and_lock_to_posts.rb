class AddAcceptedAnswerAndLockToPosts < ActiveRecord::Migration[8.1]
  def change
    add_reference :posts, :accepted_answer, foreign_key: { to_table: :answers }
    add_column :posts, :locked_at, :datetime
    add_index :posts, :locked_at
  end
end
