class User < ActiveRecord::Base
  validates :user_name, presence: true, uniqueness: true

  has_many(
    :authored_polls,
    :primary_key => :id,
    :foreign_key => :author_id,
    :class_name => 'Poll'
  )

  has_many(
    :responses,
    :primary_key => :id,
    :foreign_key => :user_id,
    :class_name => 'Response'
  )




  def completed_polls
    Poll.find_by_sql([<<-SQL, id])
          SELECT
            polls.*, COUNT(questions.id)
          FROM
            polls
          LEFT OUTER JOIN
            questions ON polls.id = questions.poll_id
          LEFT OUTER JOIN
            (
              SELECT
                *
              FROM
                responses
              WHERE
                user_id = ?
            ) AS user_responses ON questions.id = user_responses.question_id
          GROUP BY
            polls.id
          HAVING
            COUNT(questions.id) = COUNT(user_responses.id)
    SQL

  end

  #
  # def completed_polls
  #   polls = self.responses.question.poll
  #   .joins('LEFT OUTER JOIN questions ON polls.id = q uestions.poll_id')
  #   .joins('LEFT OUTER JOIN responses ON questions.id = responses.question_id')
  #   .group('polls.id')
  #   .having('COUNT(questions.id) = COUNT(responses.id)')

    # .joins('RIGHT OUTER JOIN questions ON questions.id = responses.question_id')
    # .joins('RIGHT OUTER JOIN polls ON polls.id = questions.poll_id')
    # .group('polls.id')
    # .having('COUNT(questions.id) = COUNT(responses.id)')
    #.select('polls.*')
    # polls.each do |p|
    #   puts p.id
    # end
end
