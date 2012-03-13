class Listing
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :url            , type: String
  field :date_posted    , type: Date
  field :email          , type: String
  field :phone          , type: String
  field :address        , type: String
  field :available      , type: String
  field :available_date , type: Date
  field :price          , type: Range
  field :bedrooms       , type: Range
  field :square_footage , type: Integer
  field :laundry        , type: String
  field :image_urls     , type: Array
  field :infested       , type: Boolean
  field :latlng         , type: Array, spacial: true

  # additional address fields
  field :city           , type: String
  field :postal_code    , type: String
  field :region         , type: String
  field :country        , type: String

  geocoded_by :address, :coordinates => :latlng do |listing, results|
    if geo = results.first
      listing.address     = geo.address
      listing.city        = geo.city
      listing.postal_code = geo.postal_code
      listing.region      = geo.state
      listing.country     = geo.country
      listing.latlng      = geo.coordinates
    end
  end

  set_callback(:save, :before) do |listing|
    if listing.address_changed?
      listing.geocode
      listing.check_infestation
    end
  end

  set_callback(:create, :before) do |listing|
    # find and cross reference duplicates
  end

  def check_infestation
    self.infested = ::Strategies::BedbugRegistry.address_infested?(address)
  end
end
