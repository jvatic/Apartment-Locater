namespace :craigslist do
  task :import_toronto => :environment do
    index_url = "http://toronto.en.craigslist.ca/tor/apa/"
    Strategies::Craigslist.parse_all_pages(index_url)
  end

  task :destroy_removed => :environment do
    Listing.where(:url => /craigslist/).order(:posted_at.asc).each do |listing|
      listing.destroy if Strategies::Craigslist.removed?(listing.url)
    end
  end
end
