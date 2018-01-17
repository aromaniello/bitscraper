require 'bitcointalk_scraper'

namespace :scrape do
	namespace :bitcointalk do
		task :all => :environment do
			BitcointalkScraper.scrape_all_and_save
		end
		task :new => :environment do
			BitcointalkScraper.scrape_new_and_save
		end
	end
end