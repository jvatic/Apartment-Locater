##
# Taken from https://github.com/alexreisner/geocoder/blob/master/test/test_helper.rb
# Mock HTTP request to geocoding service.
#
module Geocoder
  module Lookup
    class Base
      private #-----------------------------------------------------------------
      def read_fixture(file)
        File.read(File.join("test", "fixtures", file)).strip.gsub(/\n\s*/, "")
      end
    end

    class Google < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";   :no_results
          when "no locality";  :no_locality
          when "no city data"; :no_city_data
          else                 :madison_square_garden
        end
        read_fixture "google_#{file}.json"
      end
    end

    class GooglePremier < Google
    end

    class Yahoo < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";  :no_results
          else                :madison_square_garden
        end
        read_fixture "yahoo_#{file}.json"
      end
    end

    class Yandex < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";  :no_results
          when "invalid key"; :invalid_key
          else                :kremlin
        end
        read_fixture "yandex_#{file}.json"
      end
    end

    class GeocoderCa < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        if reverse
          read_fixture "geocoder_ca_reverse.json"
        else
          file = case query
            when "no results";  :no_results
            else                :madison_square_garden
          end
          read_fixture "geocoder_ca_#{file}.json"
        end
      end
    end

    class Freegeoip < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";  :no_results
          else                "74_200_247_59"
        end
        read_fixture "freegeoip_#{file}.json"
      end
    end

    class Bing < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        if reverse
          read_fixture "bing_reverse.json"
        else
          file = case query
            when "no results";  :no_results
            else                :madison_square_garden
          end
          read_fixture "bing_#{file}.json"
        end
      end
    end

    class Nominatim < Base
      private #-----------------------------------------------------------------
      def fetch_raw_data(query, reverse = false)
        raise TimeoutError if query == "timeout"
        raise SocketError if query == "socket_error"
        file = case query
          when "no results";  :no_results
          else                :madison_square_garden
        end
        read_fixture "nominatim_#{file}.json"
      end
    end

  end
end
