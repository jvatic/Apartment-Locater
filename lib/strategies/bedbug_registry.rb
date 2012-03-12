require 'nokogiri'
require 'open-uri'

class Strategies::BedbugRegistry
  class << self
    def address_infested?(address)
      # returns true | false | nil
    end

    def url_from_address(address)
      # converts address into lookup url
      parts = address_parts(address)
      return unless parts

      street, region = parts
      "http://www.bedbugregistry.com/search/a:#{street.gsub(/\s+/, '-')}/l:#{region.gsub(/\s+/, '-')}"
    end

    def address_parts(address)
      # splits into street address and city,region
      return unless address
      street_address = address.scan(/\d+[^,]{3,}/).first
      return unless street_address

      address = address.sub(street_address, '')

      city = address.scan(/[a-z]{3,}(?=\s*,?\s*[a-z]{2})/i).first
      prov = address.scan(/[a-z]{3,}[\s,]*([a-z]{2})/i).flatten.first
      return unless city && prov

      [street_address, "#{city} #{prov}"]
    end
  end

  def initialize(lookup_url)
    @url = lookup_url
  end

  attr_writer :doc

  def fetch
    @doc = Nokogiri::HTML( open(@url) )
  end

  def parse
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
