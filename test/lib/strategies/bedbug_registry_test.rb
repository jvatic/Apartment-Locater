require 'test_helper'

class Strategies::BedbugRegistryTest < ActiveSupport::TestCase

  def sample(num)
    @samples ||= {}
    unless @samples[num]
      s = strategy_sample(num, Strategies::BedbugRegistry)
      s.parse
    else
      s = strategy_sample(num, Strategies::BedbugRegistry)
    end
    s
  end

  test "self#url_from_address converts address into lookup url" do
    address = "218 Queen St E, Toronto, ON M5A, Canada"
    expected = "http://www.bedbugregistry.com/search/a:218-Queen-St-E/l:Toronto-ON"
    assert_equal expected, Strategies::BedbugRegistry.url_from_address(address)
  end

  test "self#url_from_address returns nil if no street address" do
    address = "Carlton St & Bleecker St, Toronto, ON M5A, Canada"
    assert_nil Strategies::BedbugRegistry.url_from_address(address)
  end

  test "self#address_parts splits address into street, city, region" do
    address = "218 Queen St E, Toronto, ON M5A, Canada"
    expected = ["218 Queen St E", "Toronto ON"]
    assert_equal expected, Strategies::BedbugRegistry.address_parts(address)
  end

  test "self#address_parts returns nil if no street address" do
    address = "Carlton St & Bleecker St, Toronto, ON M5A, Canada"
    assert_nil Strategies::BedbugRegistry.address_parts(address)
  end

  test "#parse detects infested result" do
    assert sample(1).infested?
  end

  test "#parse detects clean result" do
    assert_equal false, sample(2).infested?
  end

  test "#parse detects empty results" do
    assert_equal nil, sample(3).infested?
  end

end
