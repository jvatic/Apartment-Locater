require './boot'
require 'data_mapper'

DataMapper.setup(:default,
  :adapter  => 'mongo',
  :database => "apartment-find",
)

class Listing
  include DataMapper::Mongo::Resource

  property :id             , ObjectId
  property :url            , String
  property :title          , String
  property :posted_at      , Time
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

  def <=>(other)
    if self.available_date && other.available_date
      self.available_date <=> other.available_date
    elsif self.available == 'immediately' && other.available_date == 'immediately'
      0
    elsif self.available == 'immediately' && other.available_date && other.available_date > Time.now.to_date
      1
    elsif self.available_date && self.available_date > Time.now.to_date && other.available == 'immediately'
      -1
    else
      -1
    end
  end
end

