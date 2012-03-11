module Strategies::Matchers
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
      m = if b.to_s =~ /immediate|available now/i || string.scan(/(?:immediate)|(?:available now)/i).first
        'immediately'
      elsif b.to_s =~ /for \w+/
        b.sub(/\W+$/, '')
      elsif c = string.scan(/\bon\b([^-~,$\n]+)/i).flatten.sort_by { |i| i =~ /\d/ ? -1 : 1 }.first
        c
      else
        a
      end
      m.sub(/^\s+/, '').sub(/\s+$/, '') if m
    end

    def price(string)
      p = string.scan(/\$[.,\d]+/).first
      p.gsub(/[^.\d]/, '').to_f if p
    end

    def utilities(string)
      # returns included | extra | nil
      string.scan(/all inclusive/i).empty? ? nil : 'included'
    end

    def parking(string)
      # returns $ amount or nil
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
      n = string.scan(/\d+(?=\s*br)/).first
      n.to_f || (string.scan(/bachelor/).first ? 0 : nil)
    end

    def square_footage(string)
      sf = string.scan(/\d+(?=\s*ft|\s*sf)/i).first
      sf.to_f if sf
    end

    def available_laundry(string)
      # returns <laundry string> | nil, e.g. 'ensuite', 'on site', nil, ...
      ensuite = !string.scan(/washer\s*(?:and|\/|&|,)\s*dr[yi]er/i).empty?
      on_site = !string.scan(/laundry/).empty?
      return 'ensuite' if ensuite
      return 'on site' if on_site
    end
  end
end
