require './boot'
require 'data_mapper'

DataMapper.setup(:default,
  :adapter  => 'mongo',
  :database => "apartment-find",
)

class Listing
  include DataMapper::Resource
  include DataMapper::Mongo::Resource

  property :id             , ObjectId
  property :url            , String
  property :title          , String
  property :posted_at      , Time
  property :updated_at     , Time
  property :email          , String
  property :phone          , String
  property :available      , String
  property :available_date , Date
  property :price          , Float
  property :square_footage , Integer
  property :bedrooms       , Integer
  property :ensuite_landry , Boolean
  property :image_urls     , Array
  property :address        , Hash
  property :body_html      , String
  property :duplicate      , Boolean

  property :formatted_address , String
  property :lat               , Float
  property :lng               , Float
  property :address_type      , String
  property :geodata           , Hash
  property :city              , String
  property :region            , String
  property :country           , String

  def <=>(other)
    return 0 unless lat && lng && other.lat && other.lng
    latlng = [43.649201, -79.377839]
    a = Geocoder::Calculations.distance_between(latlng, [lat, lng])
    b = Geocoder::Calculations.distance_between(latlng, [other.lat, other.lng])
    a <=> b
  end

  def full_address
    if address[:xstreet0] && address[:xstreet1]
      "#{address[:xstreet0]} at #{address[:xstreet1]}"
    else
      [address[:GeographicArea], (address[:city] || "Toronto"), (address[:region] || "ON")].compact.join(", ")
    end
  end

  def full_address_with_region
    if address[:xstreet0] && address[:xstreet1]
      [full_address, (address[:city] || "Toronto"), (address[:region] || "ON")].compact.join(", ")
    else
      full_address
    end
  end

  def popover_content
    unless image_urls.empty?
      image_urls.inject("") do |html, url|
        html << "<img class='popover-image' src='#{url}' />"
      end
    end
  end

  def duplicate?
    duplicate || duplicates.count > 0
  end

  def duplicates
    Listing.all(:price             => price,
                :available_date    => available_date,
                :posted_at.gt      => posted_at,
                :formatted_address => formatted_address,
                :bedrooms          => bedrooms,
                :square_footage    => square_footage,
                :ensuite_landry    => ensuite_landry
               )
  end

  def geocode
    return if geodata

    result = Geocoder.search(full_address_with_region).first
    puts result.inspect
    return unless result

    self.geodata = result.data
    self.lat = geodata["geometry"]["location"]["lat"]
    self.lng = geodata["geometry"]["location"]["lng"]
    self.address_type = geodata["types"].first
    self.formatted_address = geodata["formatted_address"]
  end

end

