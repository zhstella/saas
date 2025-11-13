require 'rails_helper'

RSpec.describe ScreenPostContentJob, type: :job do
  subject(:perform_job) { described_class.perform_now(post_id) }

  let(:post) { create(:post, title: 'Suspicious title', body: 'Potential policy violation content') }
  let(:post_id) { post.id }

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end

  before do
    ENV['OPENAI_API_KEY'] = 'test-api-key'
  end

  after do
    ENV.delete('OPENAI_API_KEY')
  end

  context 'when the post cannot be found' do
    let(:post_id) { -1 }

    it 'returns without invoking the OpenAI client' do
      expect(ContentSafety::OpenaiClient).not_to receive(:new)

      expect { perform_job }.not_to raise_error
    end
  end

  context 'when the post is already AI flagged' do
    before { post.update!(ai_flagged: true) }

    it 'short-circuits the job and skips screening' do
      expect(ContentSafety::OpenaiClient).not_to receive(:new)

      perform_job
    end
  end

  context 'when the API key is missing' do
    before { ENV.delete('OPENAI_API_KEY') }

    it 'does not attempt to screen the post' do
      expect(ContentSafety::OpenaiClient).not_to receive(:new)

      perform_job
    end
  end

  context 'when the moderation API succeeds' do
    let(:client) { instance_double(ContentSafety::OpenaiClient) }
    let(:content_payload) { "#{post.title}\n\n#{post.body}" }

    before do
      allow(ContentSafety::OpenaiClient).to receive(:new).and_return(client)
    end

    it 'flags the post and logs when the content is unsafe' do
      allow(Rails.logger).to receive(:info)
      moderation_result = {
        flagged: true,
        categories: { 'violence' => true, 'hate' => false, 'sexual' => false },
        category_scores: { 'violence' => 0.95, 'hate' => 0.02, 'sexual' => 0.01 }
      }
      expect(client).to receive(:screen).with(text: content_payload).and_return(moderation_result)

      perform_job

      post.reload
      expect(post.ai_flagged?).to be(true)
      expect(post.ai_categories).to eq({ 'violence' => true, 'hate' => false, 'sexual' => false })
      expect(post.ai_scores).to eq({ 'violence' => 0.95, 'hate' => 0.02, 'sexual' => 0.01 })
      expect(Rails.logger).to have_received(:info).with(/Post ##{post.id} flagged by AI moderation/).at_least(:once)
    end

    it 'leaves the post untouched when the content is safe' do
      safe_result = {
        flagged: false,
        categories: {},
        category_scores: {}
      }
      expect(client).to receive(:screen).with(text: content_payload).and_return(safe_result)

      perform_job

      expect(post.reload.ai_flagged?).to be(false)
    end
  end

  context 'when the OpenAI client raises a missing key error' do
    before do
      allow(ContentSafety::OpenaiClient).to receive(:new)
        .and_raise(ContentSafety::OpenaiClient::MissingApiKeyError, 'missing key')
      allow(Rails.logger).to receive(:warn)
    end

    it 'logs a warning and swallows the exception' do
      expect { perform_job }.not_to raise_error
      expect(Rails.logger).to have_received(:warn).with(/OpenAI API key not configured/)
    end
  end

  context 'when an unexpected error occurs' do
    let(:client) { instance_double(ContentSafety::OpenaiClient) }

    before do
      allow(ContentSafety::OpenaiClient).to receive(:new).and_return(client)
      allow(client).to receive(:screen).and_raise(StandardError, 'API outage')
      allow(Rails.logger).to receive(:error)
    end

    it 'logs the error and re-raises so retries can handle it' do
      expect { perform_job }.to raise_error(StandardError, 'API outage')
      expect(Rails.logger).to have_received(:error).with(/Failed to screen post ##{post.id}: API outage/)
    end
  end
end
