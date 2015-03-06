class Question < ActiveRecord::Base
  validates :text, presence: true, uniqueness: true
  validates :poll_id, presence: true

  belongs_to(
  :poll,
  :primary_key => :id,
  :foreign_key => :poll_id,
  class_name: 'Poll'
  )

  has_many(
    :answer_choices,
    :primary_key => :id,
    :foreign_key => :question_id,
    :class_name => 'AnswerChoice'
  )

  has_many(
  :responses,
  through: :answer_choices,
  source: :responses
  )

  # def results
  #   choice_ids = Hash.new(0)
  #   self.reponses.each do |r|
  #     choice_ids[r.answer_choice] += 1
  #   end
  #   choice_ids
  # end

  # def results
  #   choice_ids = Hash.new
  #   answer_choices.includes(:responses).each do |c|
  #     choice_ids[c.text] = responses.lenght
  #   end
  #   choice_ids
  # end
  #
  # AnswerChoices.find_by_sql([<<-SQL, id])
  #       SELECT
  #         answer_choices.*, COUNT(responses.answer_choice_id)
  #       FROM
  #         answer_choices
  #       LEFT OUTER JOIN
  #         responses ON answer_choices.id = responses.answer_choice_id
  #       WHERE
  #         answer_choices.question_id = ?
  #       GROUP BY
  #         answer_choices.id
  #     SQL


  def results
    res = self.answer_choices
    .joins("LEFT OUTER JOIN responses ON answer_choices.id = responses.answer_choice_id")
    .group("answer_choices.id")
    .select("answer_choices.text, COUNT(responses.id) as response_count")
    # .count('responses.answer_choice_id') # , COUNT(responses.answer_choice_id))
    choice_ids = {}
    res.each do |r|
      choice_ids[r.text] = r.response_count
    end
    choice_ids
  end



end
