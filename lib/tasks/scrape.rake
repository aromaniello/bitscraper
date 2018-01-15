require 'bitcointalk_scraper'

namespace :scrape do
	task :bitcointalk => :environment do\
		BitcointalkScraper.scrape_all
	end
end