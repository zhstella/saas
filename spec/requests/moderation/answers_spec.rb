require 'rails_helper'

RSpec.describe 'Moderation::Answers', type: :request do
  let(:student) { create(:user) }
  let(:moderator) { create(:user, :moderator) }
  let(:staff) { create(:user, :staff) }
  let(:post) { create(:post, user: student) }
  let(:answer) { create(:answer, post: post, user: student, body: 'Test answer') }

  describe 'GET /moderation/answers/:id' do
    let(:redacted_answer) do
      answer.update!(
        redaction_state: 'redacted',
        redacted_by: moderator,
        redacted_reason: 'harmful_advice',
        redacted_body: 'Test answer'
      )
      answer
    end

    before do
      sign_in moderator
      AuditLog.create!(
        user: student,
        performed_by: moderator,
        auditable: redacted_answer,
        action: 'answer_redacted',
        metadata: { answer_id: redacted_answer.id, post_id: post.id, reason: 'harmful_advice' }
      )
    end

    it 'shows answer details and audit logs' do
      get moderation_answer_path(redacted_answer)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Answer Moderation')
      expect(response.body).to include('Audit Trail')
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects with access denied' do
        get moderation_answer_path(redacted_answer)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /moderation/answers/:id/redact' do
    context 'when user is a moderator' do
      before { sign_in moderator }

      it 'redacts the answer' do
        patch redact_moderation_answer_path(answer), params: {
          reason: 'harmful_advice',
          state: 'redacted'
        }

        expect(response).to redirect_to(post_path(post))
        expect(flash[:notice]).to eq('Answer has been redacted.')

        answer.reload
        expect(answer.redaction_state).to eq('redacted')
        expect(answer.redacted_by).to eq(moderator)
        expect(answer.redacted_reason).to eq('harmful_advice')
        expect(answer.redacted_body).to eq('Test answer')
      end

      it 'creates an audit log' do
        expect {
          patch redact_moderation_answer_path(answer), params: {
            reason: 'spam'
          }
        }.to change(AuditLog, :count).by(1)

        log = AuditLog.last
        expect(log.action).to eq('answer_redacted')
        expect(log.metadata['answer_id']).to eq(answer.id)
        expect(log.metadata['post_id']).to eq(post.id)
      end

      it 'supports partial redaction' do
        patch redact_moderation_answer_path(answer), params: {
          reason: 'pii',
          state: 'partial'
        }

        answer.reload
        expect(answer.redaction_state).to eq('partial')
      end

      it 'shows an alert when the service fails' do
        allow(RedactionService).to receive(:redact_answer).and_return(false)

        patch redact_moderation_answer_path(answer), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(post_path(post))
        expect(flash[:alert]).to eq('Failed to redact answer.')
      end
    end

    context 'when user is staff' do
      before { sign_in staff }

      it 'allows redaction' do
        patch redact_moderation_answer_path(answer), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(post_path(post))
        answer.reload
        expect(answer.redacted_by).to eq(staff)
      end
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects with access denied' do
        patch redact_moderation_answer_path(answer), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(root_path)
        answer.reload
        expect(answer.redaction_state).to eq('visible')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        patch redact_moderation_answer_path(answer), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /moderation/answers/:id/unredact' do
    before do
      answer.update!(
        redaction_state: 'redacted',
        redacted_by: moderator,
        redacted_reason: 'test',
        redacted_body: 'Test answer'
      )
    end

    context 'when user is a moderator' do
      before { sign_in moderator }

      it 'unredacts the answer' do
        patch unredact_moderation_answer_path(answer)

        expect(response).to redirect_to(post_path(post))
        expect(flash[:notice]).to eq('Answer has been restored.')

        answer.reload
        expect(answer.redaction_state).to eq('visible')
        expect(answer.redacted_by).to be_nil
        expect(answer.body).to eq('Test answer')
      end

      it 'creates an audit log' do
        expect {
          patch unredact_moderation_answer_path(answer)
        }.to change(AuditLog, :count).by(1)

        log = AuditLog.last
        expect(log.action).to eq('answer_unredacted')
        expect(log.metadata['answer_id']).to eq(answer.id)
      end

      it 'shows an alert when the service fails' do
        allow(RedactionService).to receive(:unredact_answer).and_return(false)

        patch unredact_moderation_answer_path(answer)

        expect(response).to redirect_to(post_path(post))
        expect(flash[:alert]).to eq('Failed to restore answer.')
      end
    end

    context 'when user is staff' do
      before { sign_in staff }

      it 'allows unredaction' do
        patch unredact_moderation_answer_path(answer)

        expect(response).to redirect_to(post_path(post))
        answer.reload
        expect(answer.redaction_state).to eq('visible')
      end
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects with access denied' do
        patch unredact_moderation_answer_path(answer)

        expect(response).to redirect_to(root_path)
        answer.reload
        expect(answer.redaction_state).to eq('redacted')
      end
    end
  end
end
