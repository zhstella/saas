require 'rails_helper'

RSpec.describe "Comments", type: :request do
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
