class Response < ActiveRecord::Base
  validates :answer_choice_id, presence: true
  validates :question_id, presence: true
  validates :user_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :respondent_is_not_author

  belongs_to(
  :answer_choice,
  primary_key: :id,
  foreign_key: :answer_choice_id,
  class_name: 'AnswerChoice'
  )

  belongs_to(
  :respondent,
  primary_key: :id,
  foreign_key: :user_id,
  class_name: 'User'
  )

  has_one(
  :question,
  through: :answer_choice,
  source: :question
  )

  def sibling_responses
    self.question.responses
    .where(':id IS NULL OR responses.id != :id', id: id)
  end

  private

  def respondent_has_not_already_answered_question
    unless sibling_responses = self.question.responses
      raise "already answered"
    end
  end

  def respondent_is_not_author
    if self.question.poll.author.id == user_id
      raise "author can't respond to own poll"
    end
  end

end
