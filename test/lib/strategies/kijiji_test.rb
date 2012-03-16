require 'test_helper'

class Strategies::KijijiTest < ActiveSupport::TestCase

  def sample(num)
    @samples ||= {}
    unless @samples[num]
      s = strategy_sample(num, Strategies::Kijiji)
      s.parse
    else
      s = strategy_sample(num, Strategies::Kijiji)
    end
    s
  end

  test "parses title" do
    assert_equal "33rd Floor Bachelor - Stunning Views - 219 Fort York Blvd.", sample(3).attributes[:title]
  end

  test "parses date listed" do
    assert_equal Time.parse("08-Mar-2012"), sample(1).attributes[:posted_at]
    assert_equal Time.parse("06-Mar-2012"), sample(6).attributes[:posted_at]
  end

  test "parses address" do
    assert_equal "1268 King St W, Toronto, ON M6K 1G6, Canada", sample(1).attributes[:address]
  end

  test "parses price" do
    assert_equal 625..625, sample(1).attributes[:price]
  end

  test "parses # bedrooms" do
    assert_equal 0..0, sample(3).attributes[:bedrooms]
    assert_equal 1..1, sample(2).attributes[:bedrooms]
  end

  test "parses phone number" do
    assert_equal '416-731-9772', sample(1).attributes[:phone]
  end

  test "parses availablility" do
    assert_equal "APRIL 1ST", sample(1).attributes[:available]
    assert_nil sample(2).attributes[:available]
  end

  test "parses availibility date" do
    assert_equal Date.parse("01-April-#{Date.today.year}"), sample(1).attributes[:available_date]
    assert_nil sample(2).attributes[:available_date]
  end

  test "parses ensuite laundry" do
    assert_equal 'ensuite', sample(2).attributes[:laundry]
    assert_equal 'ensuite', sample(4).attributes[:laundry]
    assert_nil sample(1).attributes[:laundry]
  end

  test "parses on site laundry" do
    assert_equal 'on site', sample(5).attributes[:laundry]
    assert_equal 'on site', sample(6).attributes[:laundry]
  end

  test "parses utilities" do
    assert_equal 'included', sample(6).attributes[:utilities]
    assert_equal 'extra', sample(2).attributes[:utilities]
    assert_equal 'extra', sample(4).attributes[:utilities]
  end

  test "parses image urls" do
    assert_equal [
      "http://imgc.classistatic.com/cps/kjc/120308/162r1/687989a_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/162r1/36076n7_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/163r1/4295kc1_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/163r1/1516m3k_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/164r1/2260hf1_20.jpeg"
    ], sample(1).attributes[:image_urls]
  end

  test "removed?" do
    assert sample(7).removed?
    assert !sample(2).removed?
  end

end
