require 'test_helper'

class Strategies::GottarentTest < ActiveSupport::TestCase

  def strategy_sample(num, klass)
    @samples ||= {}
    key = num
    unless @samples[key]
      name = "#{ klass.name.split('::').last.tableize }_#{num}"
      @samples[key] = klass.new("#{name}.html")
      @samples[key].doc = Nokogiri::HTML( html_fixture(name) )
      @samples[key].photos_doc = Nokogiri::HTML( html_fixture("#{name}_photos") )
    end
    @samples[key]
  end

  def sample(num, type=nil)
    @samples ||= {}
    unless @samples[num]
      s = strategy_sample(num, Strategies::Gottarent)
      s.parse
    else
      s = strategy_sample(num, Strategies::Gottarent)
    end
    s
  end

  test "parses address" do
    assert_equal "650 Parliament Street Toronto Ontario M4X 1R3 Canada", sample(1).attributes[:address]
  end

  test "parses availability" do
    assert_equal "Please call", sample(1).attributes[:available]
    assert_equal "immediately", sample(2).attributes[:available]
  end

  test "parses # bedroom range" do
    assert_equal 0..2, sample(1).attributes[:bedrooms]
  end

  test "parses price range" do
    assert_equal 680..1050, sample(1).attributes[:price]
  end

  test "parses phone number" do
    assert_equal "888-745-5383", sample(1).attributes[:phone]
  end

  test "parses photos" do
    assert_equal [
      "http://media.gottarent.com/images/952/l/Picture%20111.jpg",
      "http://media.gottarent.com/images/952/l/Picture%20105.jpg",
      "http://media.gottarent.com/images/952/l/Picture%20112.jpg",
      "http://media.gottarent.com/images/952/l/Picture%20120.jpg",
      "http://media.gottarent.com/images/952/l/Picture%20119.jpg"
    ], sample(1).attributes[:image_urls]
  end

end
