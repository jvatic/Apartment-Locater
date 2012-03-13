require 'test_helper'
require 'geocode_test_helper'

class ListingTest < ActiveSupport::TestCase
  def setup
    set_infestation false
  end

  def set_infestation(value)
    ::Strategies::BedbugRegistry.stubs(:address_infested?).returns(value)
  end

  test "Listing is geocoded before save when address changed" do
    @listing = Listing.create(:address => "4 Penn Plaza, NY, USA")
    assert_equal [40.7503540, -73.9933710], @listing.latlng

    assert_equal "New York"                             , @listing.city
    assert_equal "10001"                                , @listing.postal_code
    assert_equal "New York"                             , @listing.region
    assert_equal "United States"                        , @listing.country
    assert_equal "4 Penn Plaza, New York, NY 10001, USA", @listing.address
    assert !@listing.changed?, 'listing changes are not saved'

    assert_equal ["city"], @listing.changed
    @listing.city = "Bacon"
    @listing.save
    assert_equal "Bacon", @listing.city
  end

  test "Listing checks for bedbugs when address changed" do
    set_infestation true
    @listing = Listing.create(:address => "4 Penn Plaza, NY, USA")
    assert_equal true, @listing.infested?

    set_infestation false
    @listing.update_attribute(:city, "Bacon")
    assert_equal true, @listing.infested?

    @listing.update_attribute(:address, "4 Penn Plaza, NY")
    assert_equal false, @listing.infested?
  end
end
