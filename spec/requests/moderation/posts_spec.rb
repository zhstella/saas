require 'rails_helper'

RSpec.describe 'Moderation::Posts', type: :request do
  let(:student) { create(:user) }
  let(:moderator) { create(:user, :moderator) }
  let(:staff) { create(:user, :staff) }
  let(:post) { create(:post, user: student, body: 'Test content') }

  describe 'GET /moderation/posts' do
    context 'when user is a moderator' do
      before do
        sign_in moderator
        create(:post, user: student, redaction_state: 'redacted', redacted_body: 'Hidden content')
        create(:post, user: student, redaction_state: 'partial', redacted_body: 'Partially hidden')
        create(:post, user: student, redaction_state: 'visible')
      end

      it 'shows the moderation dashboard' do
        get moderation_posts_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Moderation Dashboard')
      end

      it 'only lists redacted and partial posts' do
        get moderation_posts_path
        expect(response.body).to include('Redacted Posts (2)')
      end
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects to root with access denied' do
        get moderation_posts_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('Access denied')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to sign in' do
        get moderation_posts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /moderation/posts/:id' do
    let(:redacted_post) do
      post.update!(
        redaction_state: 'redacted',
        redacted_by: moderator,
        redacted_reason: 'harassment',
        redacted_body: 'Test content'
      )
      post
    end

    before do
      sign_in moderator
      AuditLog.create!(
        user: student,
        performed_by: moderator,
        auditable: redacted_post,
        action: 'post_redacted',
        metadata: { post_id: redacted_post.id, reason: 'harassment' }
      )
    end

    it 'shows post details and audit logs' do
      get moderation_post_path(redacted_post)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Moderation Details')
      expect(response.body).to include('Audit Trail')
    end
  end

  describe 'PATCH /moderation/posts/:id/redact' do
    context 'when user is a moderator' do
      before { sign_in moderator }

      it 'redacts the post' do
        patch redact_moderation_post_path(post), params: {
          reason: 'spam',
          state: 'redacted'
        }

        expect(response).to redirect_to(moderation_posts_path)
        expect(flash[:notice]).to eq('Post has been redacted.')

        post.reload
        expect(post.redaction_state).to eq('redacted')
        expect(post.redacted_by).to eq(moderator)
        expect(post.redacted_reason).to eq('spam')
      end

      it 'creates an audit log' do
        expect {
          patch redact_moderation_post_path(post), params: {
            reason: 'harassment'
          }
        }.to change(AuditLog, :count).by(1)
      end

      it 'shows an alert when the service fails' do
        allow(RedactionService).to receive(:redact_post).and_return(false)

        patch redact_moderation_post_path(post), params: { reason: 'test' }

        expect(response).to redirect_to(moderation_posts_path)
        expect(flash[:alert]).to eq('Failed to redact post.')
      end
    end

    context 'when user is staff' do
      before { sign_in staff }

      it 'allows redaction' do
        patch redact_moderation_post_path(post), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(moderation_posts_path)
        post.reload
        expect(post.redacted_by).to eq(staff)
      end
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects with access denied' do
        patch redact_moderation_post_path(post), params: {
          reason: 'test'
        }

        expect(response).to redirect_to(root_path)
        post.reload
        expect(post.redaction_state).to eq('visible')
      end
    end
  end

  describe 'PATCH /moderation/posts/:id/unredact' do
    before do
      post.update!(
        redaction_state: 'redacted',
        redacted_by: moderator,
        redacted_reason: 'test',
        redacted_body: 'Test content'
      )
    end

    context 'when user is a moderator' do
      before { sign_in moderator }

      it 'unredacts the post' do
        patch unredact_moderation_post_path(post)

        expect(response).to redirect_to(moderation_posts_path)
        expect(flash[:notice]).to eq('Post has been restored.')

        post.reload
        expect(post.redaction_state).to eq('visible')
        expect(post.redacted_by).to be_nil
        expect(post.body).to eq('Test content')
      end

      it 'creates an audit log' do
        expect {
          patch unredact_moderation_post_path(post)
        }.to change(AuditLog, :count).by(1)

        log = AuditLog.last
        expect(log.action).to eq('post_unredacted')
      end

      it 'shows an alert when the service fails to restore' do
        allow(RedactionService).to receive(:unredact_post).and_return(false)

        patch unredact_moderation_post_path(post)

        expect(response).to redirect_to(moderation_posts_path)
        expect(flash[:alert]).to eq('Failed to restore post.')
      end
    end

    context 'when user is not a moderator' do
      before { sign_in student }

      it 'redirects with access denied' do
        patch unredact_moderation_post_path(post)

        expect(response).to redirect_to(root_path)
        post.reload
        expect(post.redaction_state).to eq('redacted')
      end
    end
  end
end
