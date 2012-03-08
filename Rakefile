#!/usr/bin/env rake

require './boot'
require './database'

namespace :craigslist do
  task :import_toronto do
    require './lib/scraper/craigslist'
    Scraper::Craigslist.parse_all_pages("http://toronto.en.craigslist.ca/tor/apa/")
  end
end

namespace :listings do
  task :mark_duplicates do
    Listing.all.each do |listing|
      listing.update(:duplicate => listing.duplicates.count > 0)
    end
  end

  task :geocode do
    Listing.all(:geodata => nil).each do |listing|
      listing.geocode
      listing.save
    end
  end
end
