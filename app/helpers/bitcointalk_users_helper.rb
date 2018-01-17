module BitcointalkUsersHelper

	def user_to_react(bitcointalk_user)
		{
			id: bitcointalk_user.id,
			username: bitcointalk_user.username,
			user_url: bitcointalk_user_path(bitcointalk_user),
			twitter_user_url: bitcointalk_user.twitter_user_url,
			status_count: bitcointalk_user.status_count,
			most_recent_status: bitcointalk_user.most_recent_status ? bitcointalk_user.most_recent_status.twitter_url : nil
		}
	end

	def users_to_react(bitcointalk_users)
		bitcointalk_users.map { |bitcointalk_user| user_to_react(bitcointalk_user) }
	end

	def statuses_to_react(twitter_statuses)
		twitter_statuses.map do |twitter_status|
			{
				id: twitter_status.id,
				week: twitter_status.week,
				twitter_url: twitter_status.twitter_url,
				post_date: twitter_status.post_date.strftime("%b %e, %Y %k:%M:%S"),
				created_at: twitter_status.created_at.strftime("%b %e, %Y %k:%M:%S")
			}
		end
	end

end