require 'test_helper'

class Strategies::CraigslistTest < ActiveSupport::TestCase

  def sample(num)
    @samples ||= {}
    unless @samples[num]
      s = strategy_sample(num, Strategies::Craigslist)
      s.parse
    else
      s = strategy_sample(num, Strategies::Craigslist)
    end
    s
  end

  test "parses date posted" do
    assert_equal Time.parse("2012-03-05, 12:22PM EST"), sample(1).attributes[:posted_at]
  end

  test "parses email adress" do
    assert_equal "qkgxj-2877696803@hous.craigslist.org", sample(1).attributes[:email]
  end

  test "parses phone number" do
    assert_equal "416-400-5892", sample(1).attributes[:phone]
    assert_equal "416-767-2834", sample(4).attributes[:phone]
  end

  test "parses availability" do
    assert_equal "April 1st or earlier", sample(1).attributes[:available]
    assert_equal "immediately"         , sample(3).attributes[:available]
    assert_equal "01 April 2012"       , sample(6).attributes[:available]
    assert_equal "for April"           , sample(7).attributes[:available]
    assert_nil sample(10).attributes[:available]
  end

  test "parses availability date" do
    assert_equal Date.parse("01-April-#{Date.today.year}"), sample(1).attributes[:available_date]
    assert_equal Date.parse("01-April-2012")              , sample(6).attributes[:available_date]
    assert_equal Date.parse("01-April-#{Date.today.year}"), sample(7).attributes[:available_date]
  end

  test "parses parking price" do
    assert_equal 125, sample(11).attributes[:parking]
    assert_nil sample(12).attributes[:parking]
    assert_equal 0, sample(13).attributes[:parking]
  end

  test "parses price" do
    assert_equal 1200..1200, sample(1).attributes[:price]
    assert_nil sample(2).attributes[:price]
    assert_equal 875..1355, sample(10).attributes[:price]
    assert_equal 805..805, sample(11).attributes[:price]
  end

  test "parses # of bedrooms" do
    assert_equal 1..1, sample(1).attributes[:bedrooms]
    assert_equal 0..0, sample(3).attributes[:bedrooms]
    assert_equal 0..2, sample(10).attributes[:bedrooms]
  end

  test "parses square footage" do
    assert_equal 700, sample(1).attributes[:square_footage]
    assert_equal 375, sample(3).attributes[:square_footage]
  end

  test "parses ensuite laundry" do
    assert_equal 'ensuite', sample(1).attributes[:laundry]
    assert_equal 'ensuite', sample(3).attributes[:laundry]
  end

  test "parses on site laundry" do
    assert_equal 'on site', sample(9).attributes[:laundry]
  end

  test "parse utilities included" do
    assert_equal 'included', sample(3).attributes[:utilities]
  end

  test "parse utilities extra" do
    assert_equal 'extra', sample(10).attributes[:utilities]
  end

  test "parses address" do
    assert_equal 'Logan Avenue, Toronto, ONT', sample(1).attributes[:address]
    assert_equal '17-25 Lascelles Blvd, Toronto, ON', sample(10).attributes[:address]
  end

  test "parses youtube urls" do
    assert_equal ["http://www.youtube.com/watch?v=PW5o_q6HP8s"], sample(10).attributes[:youtube_urls]
  end

  test "parses image urls" do
    assert_equal [
      "http://images.craigslist.org/5L35G35Mc3F43Lb3Ncc3564e9bc620dcf1c9e.jpg",
      "http://images.craigslist.org/5K45F25J33mc3Ia3N4c347061422d961916a3.jpg",
      "http://images.craigslist.org/5I65L35F33n43K23N6c34abeab90b83b41729.jpg",
      "http://images.craigslist.org/5I25Na5F13Gc3M23N6c34e42b9f52827c124a.jpg"
    ], sample(1).attributes[:image_urls]
  end

  test "#removed? returns true if listing no longer exists" do
    assert sample(8).removed?
  end

end
