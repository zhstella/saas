require 'rails_helper'

RSpec.describe "Likes", type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post) }

  describe "POST /posts/:post_id/likes" do
    context "when signed in" do
      it "creates a like" do
        sign_in user

        expect {
          post post_likes_path(post_record)
        }.to change(Like, :count).by(1)

        expect(response).to redirect_to(post_path(post_record))
      end

      it "allows a user to like a post" do
        sign_in user
        post post_likes_path(post_record)

        expect(post_record.liked_by?(user)).to be true
      end
    end

    context "when not signed in" do
      it "requires authentication" do
        post post_likes_path(post_record)

        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not create a like" do
        expect {
          post post_likes_path(post_record)
        }.not_to change(Like, :count)
      end
    end
  end

  describe "DELETE /posts/:post_id/likes/:id" do
    let!(:like) { create(:like, user: user, post: post_record) }

    context "when signed in as the like owner" do
      it "removes the like" do
        sign_in user

        expect {
          delete post_like_path(post_record, like)
        }.to change(Like, :count).by(-1)

        expect(response).to redirect_to(post_path(post_record))
      end

      it "makes the post no longer liked by the user" do
        sign_in user
        delete post_like_path(post_record, like)

        expect(post_record.liked_by?(user)).to be false
      end
    end

    context "when not signed in" do
      it "requires authentication" do
        delete post_like_path(post_record, like)

        expect(response).to redirect_to(new_user_session_path)
      end

      it "does not remove the like" do
        expect {
          delete post_like_path(post_record, like)
        }.not_to change(Like, :count)
      end
    end
  end
end
