class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :performed_by, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.json :metadata, null: false, default: {}
      t.references :auditable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
