require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/craigslist')

describe Scraper::Craigslist do
  before do
    @scraper = Scraper::Craigslist.new
    @scraper.doc = Nokogiri::HTML( html_fixture(:craigslist) )
    @scraper.parse!
  end

  it "should parse email address" do
    @scraper.attributes[:email].should == 'qkgxj-2877696803@hous.craigslist.org'
  end

  it "should parse phone number" do
    @scraper.attributes[:phone].should == '416-400-5892'
  end

  it "should parse avilability" do
    @scraper.attributes[:available].should == "April 1st or earlier"
    @scraper.attributes[:available_date].should == Date.strptime("01/04/2012", "%d/%m/%Y")
  end

  it "should parse price" do
    @scraper.attributes[:price].should == 1200
  end

  it "should parse square footage" do
    @scraper.attributes[:square_footage].should == 700
  end

  it "should parse # of bedrooms" do
    @scraper.attributes[:bedrooms].should == 1
  end

  it "should parse ensuite laundry" do
    @scraper.attributes[:ensuite_landry].should be_true
  end

  it "should parse address" do
    @scraper.attributes[:address][:xstreet0].should       == "Logan Avenue"
    @scraper.attributes[:address][:xstreet1].should       == "Danforth and Logan"
    @scraper.attributes[:address][:city].should           == "Toronto"
    @scraper.attributes[:address][:region].should         == "ONT"
    @scraper.attributes[:address][:GeographicArea].should == "Danforth and Logan"
  end

  it "should parse image urls" do
    @scraper.attributes[:image_urls].should == [
      "http://images.craigslist.org/5L35G35Mc3F43Lb3Ncc3564e9bc620dcf1c9e.jpg",
      "http://images.craigslist.org/5K45F25J33mc3Ia3N4c347061422d961916a3.jpg",
      "http://images.craigslist.org/5I65L35F33n43K23N6c34abeab90b83b41729.jpg",
      "http://images.craigslist.org/5I25Na5F13Gc3M23N6c34e42b9f52827c124a.jpg"]
  end
end
