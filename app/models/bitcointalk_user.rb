class BitcointalkUser < ApplicationRecord
  has_many :twitter_reports
  has_many :twitter_statuses, through: :twitter_reports

  def status_count
  	self.twitter_statuses.count
  end

  def most_recent_status
  	self.twitter_reports.order(post_date: :desc).first.last_index
  end
end
