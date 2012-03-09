require 'nokogiri'
require 'open-uri'

module Scraper
  class BedbugRegistry
    class << self
      def address_url(address)
        return unless address
        street_address = address.scan(/\d+[^,]{3,}/).first
        return unless street_address

        address = address.sub(street_address, '')

        city = address.scan(/[a-z]{3,}(?=\s*,?\s*[a-z]{2})/i).first
        prov = address.scan(/[a-z]{3,}[\s,]*([a-z]{2})/i).flatten.first
        return unless city && prov

        "http://www.bedbugregistry.com/search/a:#{street_address.gsub(/\s/, '-')}/l:#{city}-#{prov}/"
      end
    end

    def initialize(search_url=nil)
      @search_url = search_url
    end

    attr_writer :doc

    def fetch!
      @doc = Nokogiri::HTML( open(@search_url) )
    end

    def parse!
      results = @doc.css('a.address')
      if results.empty?
        @infested = nil
      elsif @doc.css('a.address.infested').size > 0
        @infested = true
      else
        @infested = false
      end
    end

    def infested?
      @infested
    end
  end
end

