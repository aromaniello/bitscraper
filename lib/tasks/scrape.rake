namespace :scrape do
	task :bitcointalk => :environment do

		scraper = Mechanize.new

		base_url = "https://bitcointalk.org/index.php?topic=2537413"
		status_base_url = "https://twitter.com/WePowerN/status/"
		twitter_user_base_url = "https://twitter.com/"
		twitter_user_base_url_alt = "https://mobile.twitter.com/"

		first_page = scraper.get(base_url)

		# get links for all pages in this topic
		page_links = first_page.links_with(class: "navPages", href: /#{base_url.gsub('/','\/').gsub('?','\?')}\.\d+/).map { |a| a.href }.uniq

		# not all are shown, so get the value for the last page
		max = page_links.map { |link| link.gsub("#{base_url}.", '').to_i }.max

		# new array to collect all twitter reports
		twitter_reports = []

		# iterate over all pages in this topic
		#(0..max).step(20).each do |num|
		(20..40).step(20).each do |num|	
			url = "#{base_url}.#{num}"

			page = scraper.get(url)

			# get the parent tag for posts that contain "TWITTER REPORT", TO DO: make an approximate matching in case of misspelling
			posts = page.search('div.post').select { |post| post.inner_html.include?("TWITTER REPORT") }.map { |p| p.parent.parent }

			posts.each do |post|

				twitter_report = {}

				# get the poster's bitcointalk username
				twitter_report[:bitcointalk_user] = post.at_css('td.poster_info b a').inner_html

				# get the post's last edit/creation date and parse it
				if post.at_css('span.edited')
					twitter_report[:last_edited] = DateTime.strptime(post.at_css('span.edited').inner_html, '%B %d, %Y, %I:%M:%S %p') # e.g. December 08, 2017, 06:57:16 PM
				else
					twitter_report[:last_edited] = DateTime.strptime(post.at_css('div.subject').parent.at_css('.smalltext').inner_html, '%B %d, %Y, %I:%M:%S %p')
				end

				twitter_report[:status_links] = []

				# iterate over links inside the post
				post.css('div.post a').each do |link|
					href = link.attribute('href').to_str

					# check if the link is the poster's twitter user url
					if (href.match(/#{twitter_user_base_url.gsub('/','\/')}\w+/) || href.match(/#{twitter_user_base_url_alt.gsub('/','\/')}\w+/)) && !href.match(/#{status_base_url.gsub('/','\/')}\w+/)
						twitter_report[:twitter_user_url] = href

					# otherwise it might be a twitter status
					elsif href.match(/https:\/\/twitter.com\/\w+\/status\/\w+/)
						twitter_report[:status_links] << href
					end
				end

				post_content = post.css('div.post a').inner_html

				# if the twitter user url is missing, look for it as plain text
				unless twitter_report[:twitter_user_url]
					twitter_report[:twitter_user_url] = post_content.match(/#{twitter_user_base_url.gsub('/','\/')}\w+/)[0]

					# if the regular url doesn't work, try the alternate one
					unless twitter_report[:twitter_user_url]
						twitter_report[:twitter_user_url] = post_content.match(/#{twitter_user_base_url_alt.gsub('/','\/')}\w+/)[0]
					end
				end
				
				# look for the week number
				if match = post_content.match(/week #?(\d+)/i)
					twitter_report[:week] = match.captures[0].to_i
				end

				twitter_reports << twitter_report
			end
		end

		# use the scraped data to populate the database
		twitter_reports.each do |tr|

			# get the bitcointalk user from the database
			user = BitcointalkUser.find_by(username: tr[:bitcointalk_user])

			# if it doesn't exist, create it
			user ||= BitcointalkUser.new(username: tr[:bitcointalk_user])

			# set the twitter user url if it exists
			user.twitter_user_url = tr[:twitter_user_url] if tr[:twitter_user_url]

			# check if the report already exists, otherwise create it
			report = user.twitter_reports.where(last_edited: tr[:last_edited]).first

			report ||= user.twitter_reports.build(last_edited: tr[:last_edited])

			report.week = tr[:week] if tr[:week]

			#tr[:status_links].each do |status_link|

			#end

			user.save
			report.save

		end
	end
end