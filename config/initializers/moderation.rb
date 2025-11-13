# Moderation configuration
# Configure moderator email whitelist via environment variable

Rails.application.config.moderator_emails =
  ENV.fetch('MODERATOR_EMAILS', '')
     .split(',')
     .map(&:strip)
     .reject(&:empty?)

Rails.logger.info "Moderator whitelist configured with #{Rails.application.config.moderator_emails.size} email(s)"
