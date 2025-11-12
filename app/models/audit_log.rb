class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :performed_by, class_name: 'User'
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true

  def self.record_identity_reveal(auditable:, actor:)
    create!(
      user: auditable.user,
      performed_by: actor,
      auditable: auditable,
      action: 'identity_revealed',
      metadata: { revealed_at: Time.current }
    )
  end
end
