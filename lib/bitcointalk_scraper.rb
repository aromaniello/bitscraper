require 'amatch'

module BitcointalkScraper
	include Amatch

	def self.scrape_all(start_from = 0)
		scraper = Mechanize.new

		base_url = "https://bitcointalk.org/index.php?topic=2537413"

		twitter_user_or_status_url = /https:\/\/(?:mobile.)?twitter.com\/[A-Za-z0-9\/]+/
		twitter_user_url = /https:\/\/twitter.com\/\w+/
		twitter_user_mobile_url = /https:\/\/mobile.twitter.com\/\w+/
		twitter_status_url = /https:\/\/twitter.com\/\w+\/status\/\w+/

		first_page = scraper.get(base_url)

		# get links for all pages in this topic
		page_links = first_page.links_with(class: "navPages", href: /#{base_url.gsub('/','\/').gsub('?','\?')}\.\d+/).map { |a| a.href }.uniq

		# not all are shown, so get the value for the last page
		max = page_links.map { |link| link.gsub("#{base_url}.", '').to_i }.max

		twitter_reports = []

		# iterate over all pages in this topic
		(start_from..max).step(20).each do |num|
			url = "#{base_url}.#{num}"

			puts "parsing #{url}"
			page = scraper.get(url)

			# get the parent tag for posts that contain "TWITTER REPORT"
			posts = page.search('div.post').select { |post| post.inner_html.include?("TWITTER REPORT") }.map { |p| p.parent.parent }

			posts.each do |post|

				twitter_report = Hash.new

				post_content = post.css('div.post').inner_html

				# skip this post if it's quoting another one
				next if post_content.match("Quote from:")

				# get the poster's bitcointalk username
				twitter_report[:bitcointalk_user] = post.at_css('td.poster_info b a').inner_html

				# get the post's last edit/creation date and parse it
				if post.at_css('span.edited')
					twitter_report[:post_date] = DateTime.strptime(post.at_css('span.edited').inner_html, '%B %d, %Y, %I:%M:%S %p') # e.g. December 08, 2017, 06:57:16 PM
				else
					twitter_report[:post_date] = DateTime.strptime(post.at_css('div.subject').parent.at_css('.smalltext').inner_html, '%B %d, %Y, %I:%M:%S %p')
				end

				twitter_report[:status_links] = []

				# look for urls as text, because they aren't always in <a> tags
				links = post_content.scan(twitter_user_or_status_url).to_a.uniq

				# iterate over links inside the post
				links.each do |link|

					# check if the link is the poster's twitter user url
					if (link.match(twitter_user_url) || link.match(twitter_user_mobile_url)) && !link.match(twitter_status_url)
						twitter_report[:twitter_user_url] = link

					# otherwise it might be a twitter status
					elsif link.match(twitter_status_url)
						twitter_report[:status_links] << link
					end
				end
				
				# look for the week number
				if week_matcher = post_content.match(/week #?(\d+)/i)
					twitter_report[:week] = week_matcher.captures[0].to_i
				end

				# wait for a second so the website doesn't kick us out
				sleep(1)

				twitter_reports << twitter_report
			end
		end
		twitter_reports
	end

	def self.save_reports(twitter_reports)
		# use the scraped data to populate the database
		twitter_reports.each do |tr|

			# get the bitcointalk user from the database
			user = BitcointalkUser.find_by(username: tr[:bitcointalk_user])

			# if it doesn't exist, create it
			user ||= BitcointalkUser.new(username: tr[:bitcointalk_user])

			# set the twitter user url if it exists
			user.twitter_user_url = tr[:twitter_user_url] if tr[:twitter_user_url]

			user.save!

			# check if the report already exists, otherwise create it
			report = user.twitter_reports.where(post_date: tr[:post_date]).first

			report ||= user.twitter_reports.build(post_date: tr[:post_date])

			report.week = tr[:week] if tr[:week]

			report.save!

			tr[:status_links].each_with_index do |status_link, index|
				report.twitter_statuses.create!(twitter_url: status_link, status_index: index)
			end
		end
	end

	def self.scrape_and_save
		self.save_reports(self.scrape_all)
	end

end