module Strategies
  class Kijiji < Base
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
