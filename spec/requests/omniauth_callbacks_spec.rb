require 'rails_helper'

RSpec.describe 'Google OAuth callbacks', type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config['omniauth.auth'] = nil
  end

  def mock_google_auth(overrides = {})
    auth_hash = {
      provider: 'google_oauth2',
      uid: 'uid-123',
      info: { email: 'student@columbia.edu' }
    }.deep_merge(overrides)

    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(auth_hash)
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  describe 'GET /users/auth/google_oauth2/callback' do
    it 'signs in allowed users and redirects to the authenticated root' do
      user = create(:user, email: 'student@columbia.edu', provider: nil, uid: nil)
      mock_google_auth(uid: 'google-uid', info: { email: user.email })

      get user_google_oauth2_omniauth_callback_path

      expect(response).to redirect_to(authenticated_root_path)
      user.reload
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('google-uid')
    end

    it 'rejects users outside the allowed domains' do
      mock_google_auth(info: { email: 'user@gmail.com' })

      expect {
        get user_google_oauth2_omniauth_callback_path
      }.not_to change(User, :count)

      expect(response).to redirect_to(unauthenticated_root_path)
      expect(flash[:alert]).to eq('Access Denied. You must use a @columbia.edu or @barnard.edu email address to log in.')
    end
  end
end
