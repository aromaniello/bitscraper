class TwitterReport < ApplicationRecord
  belongs_to :bitcointalk_user
  has_many :twitter_statuses
end
