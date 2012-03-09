require 'nokogiri'
require 'open-uri'

module Scraper
  class Kijiji
    class << self
      def parse_pages(index_url)
        doc = Nokogiri::HTML( open(index_url) )
        doc.css(".notCurrentPage a").each do |link|
          next unless link.text =~ /^\d+$/
          url = link["href"]
          parse_index(url)
        end
      end

      def parse_index(index_url)
        doc = Nokogiri::HTML( open(index_url) )
        doc.css("a.adLinkSB").each do |link|
          url = link["href"]
          parse_listing(url)
        end
      end

      def parse_listing(listing_url)
        scraper = self.new(listing_url)
        scraper.fetch!
        scraper.parse!
        return unless scraper.attributes[:posted_at] >= Date.today.prev_month.to_time
        scraper.save
        puts "Imported [#{listing_url}]"
      rescue => e
        puts "Error scraping [#{listing_url}]: #{e.to_s}\n\t#{ e.backtrace.join("\n\t") }"
      end
    end

    def initialize(listing_url=nil)
      @listing_url = listing_url
      @attributes = {}
    end

    attr_writer :doc
    attr_accessor :attributes

    def fetch!
      @doc = Nokogiri::HTML( open(@listing_url) )
    end

    def parse!
      @attributes[:url] = @listing_url
      @attributes[:title] = @doc.xpath("//h1").first.text

      @doc.css(".adcontent div, p, br, li").each { |el| el.after("\n") }
      full_text = @doc.text

      @attributes[:ensuite_landry] = !full_text.scan(/washer\s*(?:and|\/|&|,)\s*dr[yi]er/i).empty?

      date_listed = full_text.scan(/Date Listed\s*(\d{2}-[a-z]{3}-\d{2})/i).flatten.first
      @attributes[:posted_at] = Time.parse(date_listed) if date_listed

      date_edited = full_text.scan(/Last Edited\s*(\d{2}-[a-z]{3}-\d{2})/i).flatten.first
      @attributes[:updated_at] = Time.parse(date_listed) if date_edited

      address = full_text.scan(/Address(?!\!):?\s*([^\n]+)/i).flatten.sort { |b,a| a.length <=> b.length }.first
      @attributes[:address] = { :xstreet0 => address.gsub(/[^-\w\d\s,\/&]/, '').sub(/\s*$/, '') } if address

      price = full_text.scan(/Price\s*\$([\d.,]+)/).flatten.first
      @attributes[:price] = price.gsub(/[^\d.]/, '').to_f if price

      bachelor = full_text.scan(/bachelor/i).first ? true : false
      @attributes[:bedrooms] = 0 if bachelor

      phone = full_text.scan(/\(?\d{3}\)?[\s.-]+\d{3}[\s.-]+\d{4}/).first
      @attributes[:phone] = phone

      available = full_text.scan(/available ([^~.$!,\n]+)/i).flatten.select { |m| m =~ /\d/ }.first
      if available.to_s =~ /immediate/i || full_text.scan(/(?:immediate)|(?:available now)/i).first
        @attributes[:available] = 'immediately'
      elsif available
        @attributes[:available_date] = parse_date(available)
        @attributes[:available] = available.sub(/\s*$/, '')
      else
        available = full_text.scan(/available for ([^\n]+)/i).flatten.first
        @attributes[:available] = available.gsub(/[^a-z0-9\s]/i, '').sub(/\s*$/, '') if available
      end

      @attributes[:image_urls] = @doc.xpath("//td[@imggal='thumb']/img").map { |img| img["src"].sub(/14(?=\.)/, '20') }
    end

    def save
      return false unless Listing.all(:url => @listing_url).empty?
      @listing = Listing.create!(@attributes)
      @listing.geocode
      @listing.check_infestation
      @listing.save
    end

    private

    def parse_date(string)
      date = begin
               Date.parse(string)
             rescue
             end
      return date if date

      month = Date::MONTHNAMES.compact.select { |m|
        string.scan(m).first
      }.first

      day = (1..31).select { |i|
        string.scan(i.to_s).first
      }.last

      year = Time.now.year

      Date.strptime("#{day}/#{month}/#{year}", "%d/%B/%Y")
    rescue
    end
  end
end
