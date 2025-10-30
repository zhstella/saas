require 'rails_helper'

RSpec.describe "Comments", type: :request do
  describe "POST /posts/:post_id/comments" do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }

    context "when signed in with invalid data" do
      it "does not create comment with empty body" do
        sign_in user

        expect {
          post post_comments_path(post_record), params: { comment: { body: "" } }
        }.not_to change(Comment, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /posts/:post_id/comments/:id" do
    let!(:comment) { create(:comment) }
    let(:post_record) { comment.post }

    context "when the comment owner is signed in" do
      it "removes the comment" do
        sign_in comment.user, scope: :user

        expect {
          delete post_comment_path(post_record, comment)
        }.to change(Comment, :count).by(-1)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('Comment deleted.')
      end
    end

    context "when a different user is signed in" do
      it "does not remove the comment" do
        other_user = create(:user)
        sign_in other_user, scope: :user

        expect {
          delete post_comment_path(post_record, comment)
        }.not_to change(Comment, :count)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('You do not have permission')
      end
    end

    context "when not signed in" do
      it "requires authentication" do
        delete post_comment_path(post_record, comment)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
