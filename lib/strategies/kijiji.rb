module Strategies
  class Kijiji < Base
    class << self
      def parse_pages(index_url)
        doc = Nokogiri::HTML( open(index_url) )
        index_urls = [index_url].concat(doc.css(".notCurrentPage a").map do |link|
          next unless link.text =~ /^\d+$/
          link["href"]
        end)
        index_urls.each do |url|
          log "Importing [#{url}]"
          parse_index(url)
        end
      end

      def parse_index(index_url)
        doc = Nokogiri::HTML( open(index_url) )
        doc.css("a.adLinkSB").each do |link|
          url = link["href"]
          parse_listing(url) unless Listing.all_of(:url => url).count > 0
        end
      end

      def parse_listing(listing_url)
        scrape = self.new(listing_url)
        scrape.fetch
        scrape.parse
        return unless scrape.attributes[:posted_at] >= Date.today.prev_month.to_time
        if scrape.save
          log "Imported [#{listing_url}]"
        end
      rescue => e
        log "Error scraping [#{listing_url}]: #{e.to_s}\n\t#{ e.backtrace.join("\n\t") }"
      end
    end

    def parse
      super
      parse_date_posted
      parse_address
      parse_image_urls
    end

    private

    def parse_title
      @attributes[:title] = @doc.xpath("//h1").first.text
    end

    def parse_date_posted
      date_posted = @full_text.scan(/Date Listed\s*(\d{2}-[a-z]{3}-\d{2})/i).flatten.first
      date_edited = @full_text.scan(/Last Edited\s*(\d{2}-[a-z]{3}-\d{2})/i).flatten.first
      @attributes[:posted_at] = Matchers.date_time(date_edited || date_posted) if date_edited || date_posted
    end

    def parse_address
      address = @full_text.scan(/Address(?!\!):?\s*([^\n]+)/i).flatten.first
      @attributes[:address] = address.gsub(/[^-\w\d\s,\/&]/, '').sub(/^\s+/, '').sub(/\s+$/, '') if address
    end

    def parse_image_urls
      @attributes[:image_urls] = @doc.xpath("//td[@imggal='thumb']/img").map { |img| img["src"].sub(/14(?=\.)/, '20') }
    end
  end
end
