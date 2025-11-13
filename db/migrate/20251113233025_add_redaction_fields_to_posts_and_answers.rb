class AddRedactionFieldsToPostsAndAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :redaction_state, :string, default: 'visible', null: false
    add_column :posts, :redacted_body, :text
    add_reference :posts, :redacted_by, foreign_key: { to_table: :users }
    add_column :posts, :redacted_reason, :string

    add_column :answers, :redaction_state, :string, default: 'visible', null: false
    add_column :answers, :redacted_body, :text
    add_reference :answers, :redacted_by, foreign_key: { to_table: :users }
    add_column :answers, :redacted_reason, :string
  end
end
