# Background job to screen post content using OpenAI Moderation API
# Automatically flags posts that violate content policies
class ScreenPostContentJob < ApplicationJob
  queue_as :default

  # Retry on network errors
  retry_on ContentSafety::OpenaiClient::Error, wait: 5.seconds, attempts: 3

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post

    # Skip if already flagged or if no API key configured
    return if post.ai_flagged?
    return unless ENV['OPENAI_API_KEY'].present?

    begin
      # Screen the post content
      client = ContentSafety::OpenaiClient.new
      content_to_screen = "#{post.title}\n\n#{post.body}"
      result = client.screen(text: content_to_screen)

      # Update post if flagged
      if result[:flagged]
        post.update!(ai_flagged: true)
        Rails.logger.info "Post ##{post.id} flagged by AI moderation"
      end
    rescue ContentSafety::OpenaiClient::MissingApiKeyError => e
      # Skip silently if API key not configured
      Rails.logger.warn "OpenAI API key not configured, skipping content screening"
    rescue StandardError => e
      # Log error but don't fail the post creation
      Rails.logger.error "Failed to screen post ##{post.id}: #{e.message}"
      raise e # Let retry logic handle it
    end
  end
end
