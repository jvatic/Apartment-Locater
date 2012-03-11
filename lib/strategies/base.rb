require 'nokogiri'
require 'open-uri'

class Strategies::Base
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

end
