module BitcointalkUsersHelper

	def shorten_twitter_link(link)
		link_to link.gsub("https://twitter.com/",''), link if link
	end

	def most_recent_status(bitcointalk_user)
		if status = bitcointalk_user.most_recent_status
			link_to status.twitter_url.gsub("https://twitter.com/",''), status.twitter_url
		end
	end

end