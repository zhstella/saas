require 'rails_helper'

RSpec.describe "AnswerComments", type: :request do
  let(:answer) { create(:answer) }
  let(:post_record) { answer.post }

  describe "POST /posts/:post_id/answers/:answer_id/comments" do
    it "creates a comment" do
      sign_in answer.user

      expect do
        post post_answer_comments_path(post_record, answer), params: { answer_comment: { body: 'Appreciate it!' } }
      end.to change(AnswerComment, :count).by(1)

      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response.body).to include('Comment added.')
    end

    it "rejects blank bodies" do
      sign_in answer.user

      expect do
        post post_answer_comments_path(post_record, answer), params: { answer_comment: { body: '' } }
      end.not_to change(AnswerComment, :count)

      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response.body).to include("Body can&#39;t be blank")
    end
  end

  describe "DELETE /posts/:post_id/answers/:answer_id/comments/:id" do
    let!(:comment) { create(:answer_comment, answer: answer) }

    it "allows the author to delete a comment" do
      sign_in comment.user

      expect do
        delete post_answer_comment_path(post_record, answer, comment)
      end.to change(AnswerComment, :count).by(-1)

      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response.body).to include('Comment deleted.')
    end

    it "prevents other users from deleting" do
      sign_in create(:user)

      expect do
        delete post_answer_comment_path(post_record, answer, comment)
      end.not_to change(AnswerComment, :count)

      expect(response).to redirect_to(post_path(post_record))
      follow_redirect!
      expect(response.body).to include('You do not have permission to manage this comment.')
    end
  end
end
