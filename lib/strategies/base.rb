require 'nokogiri'
require 'open-uri'

module Strategies
  class Base
    def initialize(url)
      @url = url
      @attributes = { :url => @url }
      @listing = nil
    end

    attr_writer :doc
    attr_reader :attributes, :listing

    def fetch
      @doc = Nokogiri::HTML( open(@url) )
    rescue OpenURI::HTTPError, Nokogiri::SyntaxError => e
    end

    def parse
      @doc.css(".adcontent div, p, br, li").each { |el| el.after("\n") }
      @full_text = @doc.text
      parse_title
      parse_phone
      parse_bedrooms
      parse_availability
      parse_laundry
      parse_utilities
    end

    def save
      # init Listing with @attributes
      # find duplicates, cross reference
      # geocode
      # check infested
      # save
    end

    private

    def parse_title
      @attributes[:title] = @doc.title
    end

    def parse_phone
      @attributes[:phone] = Normalize.phone( Matchers.phone(@full_text) )
    end

    def parse_bedrooms
      @attributes[:bedrooms] = Matchers.num_bedrooms(@full_text)
    end

    def parse_availability
      @attributes[:available] = Matchers.available(@full_text)
      @attributes[:available_date] = Matchers.date(@attributes[:available])
    end

    def parse_laundry
      @attributes[:laundry] = Matchers.available_laundry(@full_text)
    end

    def parse_utilities
      @attributes[:utilities] = Matchers.utilities(@full_text)
    end

  end
end
