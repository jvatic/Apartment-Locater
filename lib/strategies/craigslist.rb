module Strategies
  class Craigslist < Base
    class << self
      def parse_all_pages(index_page)
        pages = [index_page].concat(10.times.map { |i| "#{index_page}index#{(i+1)*100}.html" })
        pages.each do |url|
          begin
            self.parse_listings(url)
            log "Imported [#{url}]"
          rescue => e
            log "Failed to import [#{url}]: #{e.to_s}\n\t#{e.backtrace.join("\n\t")}\n"
          end
        end
      end

      def parse_listings(index_page)
        doc = Nokogiri::HTML( open(index_page) )
        doc.xpath("//p/a").map { |a| a['href'] }.each do |listing_url|
          next if Listing.all_of(:url => listing_url).count > 0
          scrape = self.new(listing_url)
          scrape.fetch
          scrape.parse
          next unless scrape.attributes[:posted_at] >= Date.today.prev_month.to_time
          if scrape.save
            log "Imported [#{listing_url}]"
          end
        end
      end

      def removed?(listing_url)
        scrape = new(listing_url)
        scrape.fetch
        result = scrape.removed?
        log "Removed [#{listing_url}]" if result
        result
      end
    end

    def parse
      return if removed?
      super
      parse_date_posted
      parse_email_address
      parse_bedrooms
      parse_square_footage
      parse_address
      parse_image_urls
    end

    def removed?
      @doc.text.scan(/this posting has been deleted/i).first ? true : false
    end

    private

    def parse_date_posted
      posted_at = @full_text.scan(/Date:\s*([^\n]+)/).flatten.first
      @attributes[:posted_at] = Matchers.date_time(posted_at) if posted_at
    end

    def parse_email_address
      email = @doc.xpath("//a[starts-with(@href, 'mailto')]").first
      @attributes[:email] = email.text if email
    end

    def parse_square_footage
      @attributes[:square_footage] = Matchers.square_footage(@full_text)
    end

    def parse_address
      parts = @doc.xpath("//comment()").select { |n| n.text =~ /^\s*CLTAG/ }.inject({}) { |memo, data|
        key, val = data.text.scan(/(\w+)=([-.\w\s]+)/).flatten
        memo[key.to_sym] = val.sub(/\s*$/, '') if key
        memo
      }
      @attributes[:address] = [(parts[:xstreet0] || parts[:xstreet1] || parts[:GeographicArea]), parts[:city], parts[:region]].compact.join(", ")
    end

    def parse_image_urls
      @attributes[:image_urls] = @doc.xpath("//td/img").map { |img| img['src'] }
    end
  end
end
