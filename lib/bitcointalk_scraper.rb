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
		(start_from..max).step(20).each do |num|
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

		# get the parent tag for posts that are twitter reports
		posts = page.search('div.post').select { |post| is_twitter_report?(post.inner_html) }.map { |p| p.parent.parent }

		twitter_reports = []

		posts.each do |post|

			twitter_report = Hash.new

			post_content = post.css('div.post').inner_html

			# get the poster's bitcointalk username
			twitter_report[:bitcointalk_user] = post.at_css('td.poster_info b a').inner_html

			# skip this post if it's quoting another one or is the first post
			next if post_content.match("Quote from:") || twitter_report[:bitcointalk_user] == 'momopi'

			# get the post's last edit/creation date
			if post.at_css('span.edited')
				date_str = post.at_css('span.edited').inner_html
			else
				date_str = post.at_css('div.subject').parent.at_css('.smalltext').inner_html
			end

			# the date may simply read "Today" instead of displaying the whole date
			if date_str.include? "Today"
				twitter_report[:post_date] = DateTime.strptime(date_str.gsub("<b>Today</b> at ",''), '%I:%M:%S %p') # sets the date as today, and parses the time
			else
				twitter_report[:post_date] = DateTime.strptime(date_str, '%B %d, %Y, %I:%M:%S %p') # e.g. December 08, 2017, 06:57:16 PM
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

			# set the twitter user url if it exists and it's not already present
			user.twitter_user_url = twitter_report[:twitter_user_url] if twitter_report[:twitter_user_url] && !user.twitter_user_url

			user.save!

		end

		# check if the report already exists, otherwise create it
		unless report = user.twitter_reports.where(post_date: twitter_report[:post_date]).first

			report = user.twitter_reports.build(post_date: twitter_report[:post_date])

			# set the week if it exists and is not already present
			report.week = twitter_report[:week] if twitter_report[:week] && !report.week

			report.save!

			# create all twitter statuses unless they already exist in the report
			twitter_report[:status_links].each_with_index do |status_link, index|
				unless report.twitter_statuses.find_by(twitter_url: status_link)
					report.twitter_statuses.create!(twitter_url: status_link, status_index: index)
				end
			end
		end
	end

	# Check if the post is a twitter report
	# Params:
	# +post_html+:: a string with the html contents of the post
	def self.is_twitter_report?(post_html)
		post_html.include?("TWITTER REPORT") || post_html.match(TWITTER_STATUS_URL)
	end
end