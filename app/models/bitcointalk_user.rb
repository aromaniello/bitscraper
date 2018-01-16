class BitcointalkUser < ApplicationRecord
  has_many :twitter_reports
  has_many :twitter_statuses, through: :twitter_reports

  # Get the amount of statuses associated to this user
  def status_count
  	self.twitter_statuses.count
  end

  # Get the most recent status posted by this user
  def most_recent_status
  	self.twitter_reports.order(post_date: :desc).first.last_index
  end
end
