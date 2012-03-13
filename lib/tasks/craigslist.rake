namespace :craigslist do
  task :import_toronto => :environment do
    index_url = "http://toronto.en.craigslist.ca/tor/apa/"
    Strategies::Craigslist.parse_all_pages(index_url)
  end
end
