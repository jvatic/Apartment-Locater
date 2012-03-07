require 'nokogiri'
require 'open-uri'

module Scraper
  class Craigslist
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
      email = @doc.xpath("//a[starts-with(@href, 'mailto')]").first
      @attributes[:email] = email.text

      full_text = @doc.text

      if phone = full_text.scan(/\d{3}[.-]\d{3}[.-]\d{4}/)
        @attributes[:phone] = phone.first
      end

      if available = full_text.scan(/available ([^,\n]+)/i).flatten.first
        @attributes[:available] = available
        @attributes[:available_date] = parse_date(available)

        @attributes[:available] = nil if !@attributes[:available_date] && !(available =~ /immediately/i)
      end

      @attributes[:ensuite_landry] = !full_text.scan(/washer\s*(?:and|\/|&|,)\s*dryer/i).empty?

      if price = full_text.scan(/\$[.,\d]+/).first
        @attributes[:price] = price.gsub(/[^.\d]/, '').to_f
      end

      if size = full_text.scan(/\d+(?=ft)/).first
        @attributes[:square_footage] = size.to_i
      end

      if bedrooms = full_text.scan(/\d(?=br)/).first
        @attributes[:bedrooms] = bedrooms.to_i
      elsif full_text.scan(/bachelor/i).first
        @attributes[:bedrooms] = 0
      end

      @attributes[:body_html] = @doc.css("#userbody").to_html

      @attributes[:address] = @doc.xpath("//comment()").select { |n| n.text =~ /^\s*CLTAG/ }.inject({}) { |memo, data|
        key, val = data.text.scan(/(\w+)=([.\w\s]+)/).flatten
        memo[key.to_sym] = val.sub(/\s*$/, '')
        memo
      }

      @attributes[:image_urls] = @doc.xpath("//td/img").map { |img| img['src'] }
    end

    private

    def parse_date(string)
      month = Date::MONTHNAMES.compact.select { |m|
        string.scan(m).first
      }.first

      day = (1..31).select { |i|
        string.scan(i.to_s).first
      }.first

      year = Time.now.year

      return nil unless month && day

      Date.strptime("#{day}/#{month}/#{year}", "%d/%B/%Y")
    end
  end
end
