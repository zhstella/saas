require 'rails_helper'

RSpec.describe Moderation::PostsController, type: :controller do
  let(:moderator) { create(:user, :moderator) }

  before do
    sign_in moderator
  end

  describe '#index' do
    it 'handles sources that do not support pagination helpers' do
      redacted_posts = [ create(:post, redaction_state: :redacted, redacted_body: 'Hidden content') ]
      ai_flagged_posts = [ create(:post, ai_flagged: true) ]

      redacted_relation = instance_double(ActiveRecord::Relation)
      ai_flagged_relation = instance_double(ActiveRecord::Relation)

      # Mock for redacted posts
      allow(Post).to receive(:where).with(redaction_state: [ :redacted, :partial ]).and_return(redacted_relation)
      allow(redacted_relation).to receive(:includes).with(:user, :redacted_by).and_return(redacted_relation)
      allow(redacted_relation).to receive(:order).with(updated_at: :desc).and_return(redacted_posts)
      allow(redacted_posts).to receive(:respond_to?).with(:page).and_return(false)

      # Mock for AI-flagged posts
      allow(Post).to receive(:where).with(ai_flagged: true, redaction_state: 'visible').and_return(ai_flagged_relation)
      allow(ai_flagged_relation).to receive(:includes).with(:user, :redacted_by).and_return(ai_flagged_relation)
      allow(ai_flagged_relation).to receive(:order).with(updated_at: :desc).and_return(ai_flagged_posts)
      allow(ai_flagged_posts).to receive(:respond_to?).with(:page).and_return(false)

      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:redacted_posts)).to eq(redacted_posts)
      expect(assigns(:ai_flagged_posts)).to eq(ai_flagged_posts)
    end
  end
end
