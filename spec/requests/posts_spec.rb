require 'rails_helper'

RSpec.describe "Posts", type: :request do
  describe "GET /index" do
    let!(:matching_post) { create(:post, title: 'Visa renewal tips', body: 'Discuss ISSO paperwork') }
    let!(:non_matching_post) { create(:post, title: 'Dorm cooking', body: 'Best pans to buy') }

    it "redirects guests to the login page" do
      get posts_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "filters posts when a search term is present" do
      sign_in create(:user)

      get posts_path, params: { search: 'visa' }

      expect(response.body).to include('Visa renewal tips')
      expect(response.body).not_to include('Dorm cooking')
    end

    it "shows an alert when the search term is blank" do
      sign_in create(:user)

      get posts_path, params: { search: '' }

      expect(response.body).to include('Please enter text to search.')
      expect(response.body).to include('Post List')
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

        expect(response).to redirect_to(posts_path)
      end

      it "creates a thread identity for the author" do
        sign_in user

        expect {
          post posts_path, params: valid_params
        }.to change { ThreadIdentity.where(user: user).count }.by(1)
      end
    end

    context "when signed in with invalid data" do
      it "does not create post with missing title" do
        sign_in user

        expect {
          post posts_path, params: { post: { title: "", body: "Body content" } }
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not create post with missing body" do
        sign_in user

        expect {
          post posts_path, params: { post: { title: "Title", body: "" } }
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_content)
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

  describe "PATCH /posts/:id/reveal_identity" do
    let!(:post_record) { create(:post) }

    it "allows the author to reveal their identity" do
      sign_in post_record.user

      expect {
        patch reveal_identity_post_path(post_record)
      }.to change(AuditLog, :count).by(1)

      expect(post_record.reload.show_real_identity).to be(true)
      expect(response).to redirect_to(post_path(post_record))
      expect(AuditLog.last.metadata).to include('revealed_at')
    end

    it "prevents other users from revealing the identity" do
      other_user = create(:user)
      sign_in other_user

      expect {
        patch reveal_identity_post_path(post_record)
      }.not_to change(AuditLog, :count)

      expect(post_record.reload.show_real_identity).to be(false)
      expect(response).to redirect_to(post_path(post_record))
    end
  end
end
