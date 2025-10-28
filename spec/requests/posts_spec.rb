require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /index" do
    it "renders successfully for guests" do
      get posts_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /posts" do
    let(:user) { create(:user) }
    let(:valid_params) { { post: { title: 'Need visa advice', body: 'Looking for guidance on F-1 renewal.' } } }

    context "when signed in" do
      it "creates a new post" do
        sign_in user

        expect {
          post posts_path, params: valid_params
        }.to change(Post, :count).by(1)

        expect(response).to redirect_to(post_path(Post.last))
      end
    end

    context "when not signed in" do
      it "redirects to the sign-in page" do
        post posts_path, params: valid_params

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "DELETE /posts/:id" do
    let!(:post_record) { create(:post) }

    context "when the post owner is signed in" do
      it "deletes the post" do
        sign_in post_record.user

        expect {
          delete post_path(post_record)
        }.to change(Post, :count).by(-1)

        expect(response).to redirect_to(posts_path)
        follow_redirect!
        expect(response.body).to include('Post deleted.')
      end
    end

    context "when a different user is signed in" do
      it "does not delete the post" do
        other_user = create(:user)
        sign_in other_user

        expect {
          delete post_path(post_record)
        }.not_to change(Post, :count)

        expect(response).to redirect_to(post_path(post_record))
        follow_redirect!
        expect(response.body).to include('You do not have permission')
      end
    end

    context "when not signed in" do
      it "requires authentication" do
        delete post_path(post_record)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
