class TwitterStatus < ApplicationRecord
	belongs_to :twitter_report

	default_scope { order(status_index: :asc) }

	def week
		twitter_report.week
	end

	def post_date
		twitter_report.post_date
	end
end
