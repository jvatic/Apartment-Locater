module Strategies
  module Matchers
    # Helper methods for parsing data from strings
    class << self
      def address(string)
        # returns <address string> (e.g. '312 Mark St., Toronto, ON', 'Yonge St at Eglington', 'Toronto, ON', ...)
      end

      def available(string)
        # returns immediately | <availability string> (e.g. 'for April', 'Please call', ...)
        m = string.scan(/available\s+([^~.$!,\n]+)/i).flatten
        a = m.select { |m| m =~ /\d/ }.first
        b = m.first
        m = if a
              a
        elsif b.to_s =~ /immediate|available now/i || string.scan(/(?:immediate)|(?:available now)/i).first
          'immediately'
        elsif b.to_s.scan(/for \w+/).flatten.select { |i| !Date::MONTHNAMES.compact.select { |n| i =~ /#{n}/i }.empty? }.first
          b.sub(/\W+$/, '')
        elsif c = string.scan(/\b[Oo]n\b([^-~,$\n]+)/).flatten.sort_by { |i| i =~ /\d/ ? -1 : 1 }.select { |i|
            !Date::MONTHNAMES.compact.select { |n| i =~ /#{n}/i }.empty?
          }.first
          c
        end
        m.sub(/^\s+/, '').sub(/\s+$/, '') if m
      end

      def parking(string)
        # returns $ amount or nil
        return 0 if !string.scan(/(?:free parking)|(?:parking free)/i).empty?
        parking_index = (string =~ /parking/i)
        return unless parking_index
        prices = string.scan(/\$[.,\d]+/)
        price_indexes = prices.map { |i| string.index(i) }
        price_index = price_indexes.select { |i| (i - parking_index) > 0 }.sort_by { |i| i - parking_index }.first
        prices_index = price_indexes.index(price_index) if price_index
        return unless price_index
        return if (price_index - parking_index) > 25
        parking_price = prices[prices_index]
        Normalize.price(parking_price)
      end

      def price(string, parking_price=nil)
        p = string.scan(/\$[.,\d]+/).map { |i| Normalize.price(i) }.select { |i| i > 0 }.sort.uniq
        return if p.empty?
        p = p.reject { |i| i == parking_price } unless parking_price.nil?
        (p.first..p.last)
      end

      def utilities(string)
        # returns included | extra | nil
        if !string.scan(/(?:all inclusive)|(?:including\s+utilities)/i).empty?
          'included'
        elsif (hydro_index = (string =~ /hydro/i)) && (extra_index = (string =~ /extra/i))
          difference = extra_index - hydro_index
          if difference > 1 && difference < 40
            'extra'
          end
        end
      end

      def storage_locker_included?(string)
        # returns true | false
      end

      def smoking_allowed?(string)
        # returns true | false
      end

      def pets_allowed(string)
        # returns Array | nil, e.g. ['cats', 'dogs'], ['cats'], nil, ...
      end

      def email_address(string)
        # returns <email string> | nil
      end

      def phone(string)
        string.scan(/(?<=\s)\(?\d{3}\)?[\s.-]*\d{3}[\s.-]*\d{4}(?=[\s.])/).first
      end

      def date(string)
        return unless string
        d = Date.parse(string) rescue nil

        unless d
          month = Date::MONTHNAMES.compact.select { |m|
            string.scan(m).first || string.scan(/[a-z]+/i).select { |p| m.scan(p).first }.first
          }.first

          day = (1..31).select { |i| string.scan(i.to_s).first }.last

          year = Date.today.year

          d = Date.parse("#{day}-#{month}-#{year}") rescue nil
        end

        d
      end

      def date_time(string)
        Time.parse(string)
      end

      def num_bedrooms(string)
        n = string.scan(/\b\d+(?=\s*b(?:ed)?r(?:oom)?)/i)
        n ||= []
        n << (string.scan(/bachelor/).first && !string.scan(/bedrooms?\s*bachelor/).first ? 0 : nil)
        n = n.compact.map { |i| i.to_i }.sort
        (n.first..n.last) unless n.empty?
      end

      def square_footage(string)
        sf = string.scan(/\d+(?=\s*ft|\s*sf)/i).first
        sf.to_f if sf
      end

      def available_laundry(string)
        # returns <laundry string> | nil, e.g. 'ensuite', 'on site', nil, ...
        ensuite = !string.scan(/washer\s*(?:and|\/|&|,)\s*dr[yi]er/i).empty? || !string.scan(/ensuite\s+laundry/i).empty?
        on_site = !string.scan(/laundry/).empty?
        return 'ensuite' if ensuite
        return 'on site' if on_site
      end

      def youtube_urls(string)
        urls = string.scan(/(?:http:\/\/)?(?:www.)?youtube.com\/watch\?v=[^\s]+/i)
        urls.empty? ? nil : urls
      end
    end
  end
end
