class TwitterReport < ApplicationRecord
  belongs_to :bitcointalk_user
  has_many :twitter_statuses

  default_scope { order(post_date: :desc) }

  # Get the twitter status with the largest index (i.e. the latest one)
  def last_index
  	twitter_statuses.order(status_index: :asc).first
  end
end
