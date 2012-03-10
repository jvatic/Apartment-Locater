require 'nokogiri'
require 'open-uri'

module Scraper
  class Craigslist
    class << self
      def parse_all_pages(index_page)
        pages = [index_page].concat(10.times.map { |i| "#{index_page}index#{(i+1)*100}.html" })
        pages.each do |url|
          begin
            self.parse_listings(url)
            puts "Imported [#{url}]"
          rescue => e
            puts "Failed to import [#{url}]: #{e.to_s}\n\t#{e.backtrace.join("\n\t")}\n"
          end
        end
      end

      def parse_listings(index_page)
        doc = Nokogiri::HTML( open(index_page) )
        doc.xpath("//p/a").map { |a| a['href'] }.each do |listing_url|
          scrape = self.new(listing_url)
          scrape.fetch!
          scrape.parse!
          next unless scrape.attributes[:posted_at] >= Date.today.prev_month.to_time
          scrape.save
        end
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
      @attributes[:title] = @doc.title

      email = @doc.xpath("//a[starts-with(@href, 'mailto')]").first
      @attributes[:email] = email.text if email

      full_text = @doc.text

      posted_at = full_text.scan(/Date:\s*([^\n]+)/).flatten.first
      @attributes[:posted_at] = Time.parse(posted_at) if posted_at

      if phone = full_text.scan(/(?<=\s)\(?\d{3}\)?[\s.-]*\d{3}[\s.-]*\d{4}(?=[\s.])/)
        @attributes[:phone] = phone.first
      end

      if available = (full_text.scan(/available ([^-~.$!,;\n]+)/i).flatten.first || full_text.scan(/\bon\b([^-~,$\n]+)/i).flatten.sort_by { |m| m =~ /\d/ ? -1 : 1 }.first)
        @attributes[:available] = available.sub(/^\s*/, '').sub(/\s*$/, '')
        @attributes[:available_date] = parse_date(available)

        @attributes[:available] = nil unless @attributes[:available_date]
        @attributes[:available] = "immediately" if available =~ /immediate/i
      else
      end

      @attributes[:ensuite_landry] = !full_text.scan(/washer\s*(?:and|\/|&|,)\s*dr[yi]er/i).empty?

      if price = full_text.scan(/\$[.,\d]+/).first
        @attributes[:price] = price.gsub(/[^.\d]/, '').to_f
      end

      if size = full_text.scan(/\d+(?=ft|\ssf)/i).first
        @attributes[:square_footage] = size.to_i
      end

      if bedrooms = full_text.scan(/\d(?=br)/).first
        @attributes[:bedrooms] = bedrooms.to_i
      elsif full_text.scan(/bachelor/i).first
        @attributes[:bedrooms] = 0
      end

      viewit_id = full_text.scan(/vit[#=\s]+(\d+)/i).flatten.first
      @attributes[:linked_viewit_id] = viewit_id if viewit_id

      @attributes[:body_html] = @doc.css("#userbody").to_html

      @attributes[:address] = @doc.xpath("//comment()").select { |n| n.text =~ /^\s*CLTAG/ }.inject({}) { |memo, data|
        key, val = data.text.scan(/(\w+)=([.\w\s]+)/).flatten
        memo[key.to_sym] = val.sub(/\s*$/, '') if key
        memo
      }

      @attributes[:image_urls] = @doc.xpath("//td/img").map { |img| img['src'] }
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
        string.scan(/\b#{i.to_s}\b/).first
      }.last

      year = Time.now.year

      Date.strptime("#{day}/#{month}/#{year}", "%d/%B/%Y")
    rescue
    end
  end
end
