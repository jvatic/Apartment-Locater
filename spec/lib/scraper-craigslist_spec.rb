require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/craigslist')

describe Scraper::Craigslist do
  before do
    @sample1 = Scraper::Craigslist.new
    @sample1.doc = Nokogiri::HTML( html_fixture(:craigslist) )
    @sample1.parse!

    @sample2 = Scraper::Craigslist.new
    @sample2.doc = Nokogiri::HTML( html_fixture(:craigslist2) )
    @sample2.parse!

    @sample3 = Scraper::Craigslist.new
    @sample3.doc = Nokogiri::HTML( html_fixture(:craigslist3) )
    @sample3.parse!

    @sample4 = Scraper::Craigslist.new
    @sample4.doc = Nokogiri::HTML( html_fixture(:craigslist4) )
    @sample4.parse!
  end

  it "should parse email address" do
    @sample1.attributes[:email].should == 'qkgxj-2877696803@hous.craigslist.org'
    @sample2.attributes[:email].should == 'gzmch-2880994574@hous.craigslist.org'
    @sample3.attributes[:email].should == 'fj9pw-2884560373@hous.craigslist.org'
    @sample4.attributes[:email].should == 'noman.khan@century21.ca'
  end

  it "should parse phone number" do
    @sample1.attributes[:phone].should == '416-400-5892'
    @sample2.attributes[:phone].should == '647.706.8245'
    @sample3.attributes[:phone].should be_nil
    @sample4.attributes[:phone].should == '416-707-7815'
  end

  it "should parse avilability" do
    @sample1.attributes[:available].should == "April 1st or earlier"
    @sample1.attributes[:available_date].should == Date.strptime("01/04/2012", "%d/%m/%Y")

    @sample2.attributes[:available].should be_nil
    @sample2.attributes[:available_date].should be_nil

    @sample3.attributes[:available].should == 'immediately'
    @sample3.attributes[:available_date].should be_nil

    @sample4.attributes[:available].should be_nil
    @sample4.attributes[:available_date].should be_nil
  end

  it "should parse price" do
    @sample1.attributes[:price].should == 1200
    @sample2.attributes[:price].should be_nil
    @sample3.attributes[:price].should == 795
    @sample4.attributes[:price].should == 1200
  end

  it "should parse square footage" do
    @sample1.attributes[:square_footage].should == 700
    @sample2.attributes[:square_footage].should be_nil
    @sample3.attributes[:square_footage].should == 375
    @sample4.attributes[:square_footage].should == 375
  end

  it "should parse # of bedrooms" do
    @sample1.attributes[:bedrooms].should == 1
    @sample2.attributes[:bedrooms].should == 1
    @sample3.attributes[:bedrooms].should == 0
    @sample4.attributes[:bedrooms].should == 0
  end

  it "should parse ensuite laundry" do
    @sample1.attributes[:ensuite_landry].should be_true
    @sample2.attributes[:ensuite_landry].should be_true
    @sample3.attributes[:ensuite_landry].should be_true
    @sample4.attributes[:ensuite_landry].should be_true
  end

  it "should parse address" do
    @sample1.attributes[:address][:xstreet0].should       == "Logan Avenue"
    @sample1.attributes[:address][:xstreet1].should       == "Danforth and Logan"
    @sample1.attributes[:address][:city].should           == "Toronto"
    @sample1.attributes[:address][:region].should         == "ONT"
    @sample1.attributes[:address][:GeographicArea].should == "Danforth and Logan"

    @sample2.attributes[:address][:xstreet0].should       == "1 King St. W."
    @sample2.attributes[:address][:xstreet1].should       == "Yonge St."
    @sample2.attributes[:address][:city].should           == "Toronto"
    @sample2.attributes[:address][:region].should         == "ON"
    @sample2.attributes[:address][:GeographicArea].should == "1 King St. W."
  end

  it "should parse image urls" do
    @sample1.attributes[:image_urls].should == [
      "http://images.craigslist.org/5L35G35Mc3F43Lb3Ncc3564e9bc620dcf1c9e.jpg",
      "http://images.craigslist.org/5K45F25J33mc3Ia3N4c347061422d961916a3.jpg",
      "http://images.craigslist.org/5I65L35F33n43K23N6c34abeab90b83b41729.jpg",
      "http://images.craigslist.org/5I25Na5F13Gc3M23N6c34e42b9f52827c124a.jpg"]

    @sample2.attributes[:image_urls].should == [
      "http://images.craigslist.org/5Ld5F85H63Ld3M43H1c326abb3b63327012cd.jpg",
      "http://images.craigslist.org/5N35Kc5F33I33m03Hfc32d68ef5da62f9153c.jpg",
      "http://images.craigslist.org/5If5N85Ge3L33Ma3Icc3243f85d404efd1796.jpg",
      "http://images.craigslist.org/5Ie5Gb5V33Le3Jb3N7c32ba53a345452c16d6.jpg"]
  end
end
