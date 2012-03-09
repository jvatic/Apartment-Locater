require 'nokogiri'
require 'open-uri'

module Scraper
  class Viewit
    class << self
      def vit_url(vit)
        "http://www.viewit.ca/#{vit}"
      end
    end

    def initialize(listing_url=nil)
      @listing_url = listing_url
      @attributes = {}
    end

    attr_writer :doc
    attr_reader :attributes

    def fetch!
      @doc = Nokogiri::HTML( open(@listing_url) )
    end

    def parse!
      @attributes[:url] = @listing_url
      @attributes[:title] = @doc.css("meta[name=title]").first["content"]
      @attributes[:body_html] = @doc.css("meta[name=description]").first["content"]

      street_address = @doc.css("#ctl00_ContentPlaceHolder1_lbNameAddress").text
      @attributes[:address] = {}
      @attributes[:address][:xstreet0] = street_address.scan(/[-a-z0-9,#.]+(?=[^-a-z0-9,#.]+)/i).join(" ") # viewit has some strange chars

      price = @doc.css("#ctl00_ContentPlaceHolder1_lblPrice").text.scan(/[\d,.]+/).first
      @attributes[:price] = price.gsub(/[^\d.]/, '').to_f if price

      bedrooms = @doc.text.scan(/\d+(?=\s*bedroom)/).first
      @attributes[:bedrooms] = bedrooms.to_i if bedrooms

      phone = @doc.css("#ctl00_ContentPlaceHolder1_lblContactInfo").text.scan(/\d{3,4}/).join("-")
      @attributes[:phone] = phone if phone.length >= 12

      vit = @attributes[:title].scan(/vit[\s#]+(\d+)/i).flatten.first
      @attributes[:viewit_id] = vit

      image_urls = @doc.xpath("//img[starts-with(@src, 'http://images.viewit.ca/#{vit}')]").to_a
      floor_plan_image = @doc.css("#ctl00_ContentPlaceHolder1_floorplan_img").first
      image_urls << floor_plan_image if floor_plan_image
      @attributes[:image_urls] = image_urls.map { |img| img["src"] }.select { |url| url =~ /#{vit}\/\w+/i }.map { |url| url.sub(/_small/, '') }.uniq

      @attributes[:ensuite_landry] = !@doc.text.scan(/washer\s*(?:and|\/|&|,)\s*dr[yi]er/i).empty?

      if available = @doc.text.scan(/available ([^-~.$!,\n]+)/i).flatten.first
        @attributes[:available] = available
        @attributes[:available_date] = parse_date(available)

        @attributes[:available] = nil unless @attributes[:available_date]
        @attributes[:available] = "immediately" if available =~ /immediate/i
      end
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
