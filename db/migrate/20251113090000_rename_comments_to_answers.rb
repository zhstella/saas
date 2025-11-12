class RenameCommentsToAnswers < ActiveRecord::Migration[8.1]
  def up
    rename_table :comments, :answers

    execute <<~SQL
      UPDATE audit_logs
      SET auditable_type = 'Answer'
      WHERE auditable_type = 'Comment'
    SQL
  end

  def down
    execute <<~SQL
      UPDATE audit_logs
      SET auditable_type = 'Comment'
      WHERE auditable_type = 'Answer'
    SQL

    rename_table :answers, :comments
  end
end
