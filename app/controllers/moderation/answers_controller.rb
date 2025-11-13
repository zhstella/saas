# Moderation controller for managing answer redactions
module Moderation
  class AnswersController < ApplicationController
    before_action :require_moderator!
    before_action :set_answer, only: [ :show, :redact, :unredact ]

    # GET /moderation/answers/:id
    # Show answer details and audit trail
    def show
      @post = @answer.post
      @audit_logs = @answer.audit_logs.includes(:performed_by).order(created_at: :desc)
    end

    # PATCH /moderation/answers/:id/redact
    # Redact an answer
    def redact
      reason = params[:reason].presence || 'policy_violation'
      state = params[:state]&.to_sym || :redacted

      if RedactionService.redact_answer(
        answer: @answer,
        moderator: current_user,
        reason: reason,
        state: state
      )
        redirect_to post_path(@answer.post), notice: 'Answer has been redacted.'
      else
        redirect_to post_path(@answer.post), alert: 'Failed to redact answer.'
      end
    end

    # PATCH /moderation/answers/:id/unredact
    # Restore a redacted answer
    def unredact
      if RedactionService.unredact_answer(
        answer: @answer,
        moderator: current_user
      )
        redirect_to post_path(@answer.post), notice: 'Answer has been restored.'
      else
        redirect_to post_path(@answer.post), alert: 'Failed to restore answer.'
      end
    end

    private

    def set_answer
      @answer = Answer.find(params[:id])
    end
  end
end
