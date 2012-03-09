require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/craigslist')

describe Scraper::Craigslist do
  def sample(num)
    @samples ||= {}
    unless @samples[num]
      @samples[num] = Scraper::Craigslist.new
      @samples[num].doc = Nokogiri::HTML( html_fixture("craigslist#{num}") )
      @samples[num].parse!
    end
    @samples[num]
  end

  it "should parse date posted" do
    sample(1).attributes[:posted_at].should == Time.parse("2012-03-05, 12:22PM EST")
  end

  it "should parse email address" do
    sample(1).attributes[:email].should == 'qkgxj-2877696803@hous.craigslist.org'
    sample(2).attributes[:email].should == 'gzmch-2880994574@hous.craigslist.org'
    sample(3).attributes[:email].should == 'fj9pw-2884560373@hous.craigslist.org'
    sample(4).attributes[:email].should == 'noman.khan@century21.ca'
  end

  it "should parse phone number" do
    sample(1).attributes[:phone].should == '416-400-5892'
    sample(2).attributes[:phone].should == '647.706.8245'
    sample(3).attributes[:phone].should be_nil
    sample(4).attributes[:phone].should == '416-707-7815'
    sample(5).attributes[:phone].should == '(416) 767-2834'

    sample(6).attributes[:phone].should == '416 531 7299'
    sample(7).attributes[:phone].should == '416 -- 618 4214'
  end

  it "should parse avilability" do
    sample(1).attributes[:available].should == "April 1st or earlier"
    sample(1).attributes[:available_date].should == Date.strptime("01/04/2012", "%d/%m/%Y")

    sample(2).attributes[:available].should be_nil
    sample(2).attributes[:available_date].should be_nil

    sample(3).attributes[:available].should == 'immediately'
    sample(3).attributes[:available_date].should be_nil

    sample(4).attributes[:available].should be_nil
    sample(4).attributes[:available_date].should be_nil

    sample(5).attributes[:available].should == "February 19th"
    sample(5).attributes[:available_date].should == Date.strptime("19/02/2012", "%d/%m/%Y")
  end

  it "should parse price" do
    sample(1).attributes[:price].should == 1200
    sample(2).attributes[:price].should be_nil
    sample(3).attributes[:price].should == 795
    sample(4).attributes[:price].should == 1200
    sample(5).attributes[:price].should == 985
  end

  it "should parse square footage" do
    sample(1).attributes[:square_footage].should == 700
    sample(2).attributes[:square_footage].should be_nil
    sample(3).attributes[:square_footage].should == 375
    sample(4).attributes[:square_footage].should == 375
    sample(5).attributes[:square_footage].should be_nil
  end

  it "should parse # of bedrooms" do
    sample(1).attributes[:bedrooms].should == 1
    sample(2).attributes[:bedrooms].should == 1
    sample(3).attributes[:bedrooms].should == 0
    sample(4).attributes[:bedrooms].should == 0
    sample(5).attributes[:bedrooms].should == 1
  end

  it "should parse ensuite laundry" do
    sample(1).attributes[:ensuite_landry].should be_true
    sample(2).attributes[:ensuite_landry].should be_true
    sample(3).attributes[:ensuite_landry].should be_true
    sample(4).attributes[:ensuite_landry].should be_true
    sample(5).attributes[:ensuite_landry].should be_true
    sample(7).attributes[:ensuite_landry].should be_true
  end

  it "should parse address" do
    sample(1).attributes[:address][:xstreet0].should       == "Logan Avenue"
    sample(1).attributes[:address][:xstreet1].should       == "Danforth and Logan"
    sample(1).attributes[:address][:city].should           == "Toronto"
    sample(1).attributes[:address][:region].should         == "ONT"
    sample(1).attributes[:address][:GeographicArea].should == "Danforth and Logan"

    sample(2).attributes[:address][:xstreet0].should       == "1 King St. W."
    sample(2).attributes[:address][:xstreet1].should       == "Yonge St."
    sample(2).attributes[:address][:city].should           == "Toronto"
    sample(2).attributes[:address][:region].should         == "ON"
    sample(2).attributes[:address][:GeographicArea].should == "1 King St. W."
  end

  it "should parse linked viewit id" do
    sample(1).attributes[:linked_viewit_id].should == "121738"
  end

  it "should parse image urls" do
    sample(1).attributes[:image_urls].should == [
      "http://images.craigslist.org/5L35G35Mc3F43Lb3Ncc3564e9bc620dcf1c9e.jpg",
      "http://images.craigslist.org/5K45F25J33mc3Ia3N4c347061422d961916a3.jpg",
      "http://images.craigslist.org/5I65L35F33n43K23N6c34abeab90b83b41729.jpg",
      "http://images.craigslist.org/5I25Na5F13Gc3M23N6c34e42b9f52827c124a.jpg"]

    sample(2).attributes[:image_urls].should == [
      "http://images.craigslist.org/5Ld5F85H63Ld3M43H1c326abb3b63327012cd.jpg",
      "http://images.craigslist.org/5N35Kc5F33I33m03Hfc32d68ef5da62f9153c.jpg",
      "http://images.craigslist.org/5If5N85Ge3L33Ma3Icc3243f85d404efd1796.jpg",
      "http://images.craigslist.org/5Ie5Gb5V33Le3Jb3N7c32ba53a345452c16d6.jpg"]
  end
end
