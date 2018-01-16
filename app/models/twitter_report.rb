class TwitterReport < ApplicationRecord
  belongs_to :bitcointalk_user
  has_many :twitter_statuses

  default_scope { order(post_date: :desc) }

  def last_index
  	twitter_statuses.order(status_index: :asc).first
  end
end
