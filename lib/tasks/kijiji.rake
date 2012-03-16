namespace :kijiji do
  task :import_toronto => :environment do
    Strategies::Kijiji.parse_pages("http://toronto.kijiji.ca/f-real-estate-apartments-condos-bachelor-studio-City-of-Toronto-W0QQAdTypeZ2QQCatIdZ211QQLocationZ1700273QQisSearchFormZtrue")
    # short term:
    # Strategies::Kijiji.parse_pages("http://toronto.kijiji.ca/f-immediately-real-estate-short-term-rentals-W0QQCatIdZ42QQKeywordZimmediatelyQQisSearchFormZtrue")
  end

  task :destroy_removed => :environment do
    Listing.where(:url => /kijiji/).order(:posted_at.asc).each do |listing|
      listing.destroy if Strategies::Kijiji.removed?(listing.url)
    end
  end
end
