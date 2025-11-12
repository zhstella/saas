require 'rails_helper'

RSpec.describe AuditLog, type: :model do
  describe '.record_identity_reveal' do
    it 'creates an audit entry referencing the auditable and actor' do
      post_record = create(:post)
      actor = post_record.user

      expect {
        described_class.record_identity_reveal(auditable: post_record, actor: actor)
      }.to change(described_class, :count).by(1)

      log = described_class.last
      expect(log.user).to eq(post_record.user)
      expect(log.performed_by).to eq(actor)
      expect(log.auditable).to eq(post_record)
      expect(log.action).to eq('identity_revealed')
    end
  end
end
