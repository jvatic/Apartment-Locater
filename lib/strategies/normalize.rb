module Strategies::Normalize
  class << self
    def phone(string)
      return unless string
      string.gsub(/\D/, '').scan(/(\d)?(\d{3})(\d{3})(\d{4})/).flatten.compact.join("-")
    end
  end
end
