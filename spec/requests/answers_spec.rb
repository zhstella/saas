require 'rails_helper'

RSpec.describe "Answers", type: :request do
  describe "POST /posts/:post_id/answers" do
    let(:user) { create(:user) }
    let!(:post_record) { create(:post) }

    context "when signed in with invalid data" do
      it "does not create an answer with empty body" do
        sign_in user

        expect {
          post post_answers_path(post_record), params: { answer: { body: "" } }
        }.not_to change(Answer, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context "when signed in with valid data" do
      it "creates the answer and thread identity" do
        sign_in user

        expect {
          post post_answers_path(post_record), params: { answer: { body: "Insight" } }
        }.to change(Answer, :count).by(1)
         .and change { ThreadIdentity.where(user: user, post: post_record).count }.from(0).to(1)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('Answer added.')
      end
    end

    context "when the thread is locked" do
      it "rejects new answers" do
        sign_in user
        post_record.update(locked_at: Time.current)

        expect {
          post post_answers_path(post_record), params: { answer: { body: "Nope" } }
        }.not_to change(Answer, :count)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('This thread is locked. No new answers can be added.')
      end
    end
  end

  describe "DELETE /posts/:post_id/answers/:id" do
    let!(:answer) { create(:answer) }
    let(:post_record) { answer.post }

    context "when the answer owner is signed in" do
      it "removes the answer" do
        sign_in answer.user, scope: :user

        expect {
          delete post_answer_path(post_record, answer)
        }.to change(Answer, :count).by(-1)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('Answer deleted.')
      end
    end

    context "when a different user is signed in" do
      it "does not remove the answer" do
        other_user = create(:user)
        sign_in other_user, scope: :user

        expect {
          delete post_answer_path(post_record, answer)
        }.not_to change(Answer, :count)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('You do not have permission')
      end
    end

    context "when not signed in" do
      it "requires authentication" do
        delete post_answer_path(post_record, answer)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /posts/:post_id/answers/:id/reveal_identity" do
    let!(:answer) { create(:answer) }
    let(:post_record) { answer.post }

    it "allows the answer author to reveal their identity" do
      sign_in answer.user

      expect {
        patch reveal_identity_post_answer_path(post_record, answer)
      }.to change(AuditLog, :count).by(1)

      expect(answer.reload.show_real_identity).to be(true)
      expect(response).to redirect_to(post_path(post_record))
      expect(AuditLog.last.metadata).to include('revealed_at')
    end

    it "prevents other users from revealing the identity" do
      other_user = create(:user)
      sign_in other_user

      expect {
        patch reveal_identity_post_answer_path(post_record, answer)
      }.not_to change(AuditLog, :count)

      expect(answer.reload.show_real_identity).to be(false)
      expect(response).to redirect_to(post_path(post_record))
    end
  end

  describe "PATCH /posts/:post_id/answers/:id/accept" do
    let!(:post_record) { create(:post) }
    let!(:answer) { create(:answer, post: post_record) }

    it "locks the thread when the author accepts an answer" do
      sign_in post_record.user

      patch accept_post_answer_path(post_record, answer)

      expect(response).to redirect_to(post_path(post_record))
      expect(post_record.reload.locked?).to be(true)
      expect(post_record.accepted_answer).to eq(answer)
    end

    it "prevents other users from accepting answers" do
      sign_in create(:user)

      patch accept_post_answer_path(post_record, answer)

      expect(response).to redirect_to(post_path(post_record))
      expect(post_record.reload.accepted_answer).to be_nil
    end
  end

  describe "PATCH /posts/:id/unlock" do
    let!(:post_record) { create(:post) }

    it "allows the post author to reopen a thread" do
      answer = create(:answer, post: post_record)
      post_record.update(accepted_answer: answer, locked_at: Time.current)
      sign_in post_record.user

      patch unlock_post_path(post_record)

      expect(response).to redirect_to(post_path(post_record))
      expect(post_record.reload.locked?).to be(false)
      expect(post_record.accepted_answer).to be_nil
    end
  end
end
