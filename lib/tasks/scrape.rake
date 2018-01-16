require 'bitcointalk_scraper'

namespace :scrape do
	task :bitcointalk => :environment do
		BitcointalkScraper.scrape_and_save
	end
end