module Strategies
  class Gottarent < Base

    attr_writer :photos_doc

    def parse
      prepare_doc

      parse_address

      parse_variants
      parse_availability
      parse_bedrooms
      parse_price

      parse_phone
      parse_image_urls
    end

    private

    def parse_address
      address = @doc.css("#addr h3").first
      @attributes[:address] = address.text.gsub(/[\r\n]+/, ' ').sub(/^\s+/, '').sub(/\s+$/, '') if address
    end

    def parse_variants
      variants_table = @doc.css("#dnn_ctr484_ViewApartmentDetailsInformation_overtab_availiabilityDiv table").first
      @variants = variants_table.css("tbody tr").inject([]) do |memo, variant_row|
        variant = {}
        variant[:bedrooms]  = variant_row.css("td,th")[4].text
        variant[:price]     = variant_row.css("td,th")[2].text.gsub(/[^\d.]/, '').to_f
        variant[:available] = variant_row.css("td,th")[3].text.gsub(/\r/, '')

        variant[:available] = "immediately" if variant[:available] =~ /available/i
        variant[:available_date] = Matchers.date(variant[:available])

        if variant[:bedrooms].scan(/bach|studio/i).first
          variant[:bedrooms] = 0
        else
          variant[:bedrooms] = variant[:bedrooms].scan(/\d+(?=\s*bedroom)/i).first.to_i
        end

        memo << variant unless variant[:available] =~ /No Availability/i
        memo
      end
    end

    def parse_availability
      return if @variants.empty?
      first_variant = @variants.select { |v| v[:available_date] != nil }.sort_by { |v| v[:available_date] }.first
      first_variant ||= @variants.select { |v| v[:available] == 'immediately' }.first
      first_variant ||= @variants.first
      @attributes[:available] = first_variant[:available] if first_variant
    end

    def parse_bedrooms
      return if @variants.empty?
      bedrooms = @variants.map { |v| v[:bedrooms] }.compact.sort
      @attributes[:bedrooms] = (bedrooms.first..bedrooms.last) unless bedrooms.empty?
    end

    def parse_price
      return if @variants.empty?
      price = @variants.map { |v| v[:price] }.compact.sort
      @attributes[:price] = (price.first..price.last) unless price.empty?
    end

    def parse_image_urls
      return unless @photos_doc
      @attributes[:image_urls] = @photos_doc.css("img[onclick]").map do |img|
        URI.escape(img["src"].gsub(/(?<=\/)s/, 'l'))
      end
    end

  end
end
