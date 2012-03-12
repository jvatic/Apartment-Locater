module Strategies
  class Craigslist < Base
    def parse
      return if removed?
      super
      parse_date_posted
      parse_email_address
      parse_price
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

    def parse_price
      @attributes[:price] = Matchers.price(@full_text)
    end

    def parse_square_footage
      @attributes[:square_footage] = Matchers.square_footage(@full_text)
    end

    def parse_address
      parts = @doc.xpath("//comment()").select { |n| n.text =~ /^\s*CLTAG/ }.inject({}) { |memo, data|
        key, val = data.text.scan(/(\w+)=([.\w\s]+)/).flatten
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
