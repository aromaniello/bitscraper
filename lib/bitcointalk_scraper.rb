module BitcointalkScraper

	BASE_URL = "https://bitcointalk.org/index.php?topic=2537413"

	TWITTER_USER_OR_STATUS_URL = /https:\/\/(?:mobile.)?twitter.com\/[A-Za-z0-9\/]+/
	TWITTER_USER_URL = /https:\/\/twitter.com\/\w+/
	TWITTER_USER_MOBILE_URL = /https:\/\/mobile.twitter.com\/\w+/
	TWITTER_STATUS_URL = /https:\/\/twitter.com\/\w+\/status\/\w+/

	# Scrape all pages in this topic
	# Params:
	# +start_from+:: optional page where to start scraping (defaults to 0)
	def self.scrape_and_save(start_from = 0)

		scraper = Mechanize.new

		first_page = scraper.get(BASE_URL)

		# get links for all pages in this topic
		page_links = first_page.links_with(class: "navPages", href: /#{BASE_URL.gsub('/','\/').gsub('?','\?')}\.\d+/).map { |a| a.href }.uniq

		# not all are shown, so get the value for the last page
		max = page_links.map { |link| link.gsub("#{BASE_URL}.", '').to_i }.max

		# iterate over all pages in this topic
		#(start_from..max).step(20).each do |num|
		(20..80).step(20).each do |num|
			url = "#{BASE_URL}.#{num}"

			puts "parsing #{url}"

			# scrape this page and return an array of twitter reports
			twitter_reports = scrape_page(url, scraper)

			# save these reports to the database
			twitter_reports.map { |twitter_report| save_report(twitter_report) }

			# wait for a second so the website doesn't kick us out
			sleep(1)
		end
	end

	# Scrape a single page and return all twitter reports found within
	# Params:
	# +url+:: the url of the page to be scraped
	# +scraper+:: the mechanize object used for scraping
	def self.scrape_page(url, scraper)

		page = scraper.get(url)

		# get the parent tag for posts that contain "TWITTER REPORT"
		posts = page.search('div.post').select { |post| post.inner_html.include?("TWITTER REPORT") }.map { |p| p.parent.parent }

		twitter_reports = []

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
			links = post_content.scan(TWITTER_USER_OR_STATUS_URL).to_a.uniq

			# iterate over links inside the post
			links.each do |link|

				# check if the link is the poster's twitter user url
				if (link.match(TWITTER_USER_URL) || link.match(TWITTER_USER_MOBILE_URL)) && !link.match(TWITTER_STATUS_URL)
					twitter_report[:twitter_user_url] = link

				# otherwise it might be a twitter status
				elsif link.match(TWITTER_STATUS_URL)
					twitter_report[:status_links] << link
				end
			end
			
			# look for the week number
			if week_matcher = post_content.match(/week #?(\d+)/i)
				twitter_report[:week] = week_matcher.captures[0].to_i
			end

			twitter_reports << twitter_report
		end

		twitter_reports
	end	

	# Save a scraped twitter report to the database, and create the user if it doesn't already exist
	# Params:
	# +twitter_report+:: a hash with the data to create a twitter report
	def self.save_report(twitter_report)

		unless user = BitcointalkUser.find_by(username: twitter_report[:bitcointalk_user])
			user = BitcointalkUser.new(username: twitter_report[:bitcointalk_user])
		end

		# set the twitter user url if it exists and it's not already present
		user.twitter_user_url = twitter_report[:twitter_user_url] if twitter_report[:twitter_user_url] && !user.twitter_user_url

		user.save!

		# check if the report already exists, otherwise create it
		unless report = user.twitter_reports.where(post_date: twitter_report[:post_date]).first
			report = user.twitter_reports.build(post_date: twitter_report[:post_date])
		end

		# set the week if it exists and is not already present
		report.week = twitter_report[:week] if twitter_report[:week] && !report.week

		report.save!

		twitter_report[:status_links].each_with_index do |status_link, index|
			report.twitter_statuses.create!(twitter_url: status_link, status_index: index)
		end
	end

end