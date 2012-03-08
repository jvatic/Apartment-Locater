require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/kijiji')

describe Scraper::Kijiji do
  def sample(num)
    @samples ||= {}
    unless @samples[num]
      @samples[num] = Scraper::Kijiji.new
      @samples[num].doc = Nokogiri::HTML( html_fixture("kijiji#{num}") )
      @samples[num].instance_variable_set("@listing_url", "#{num}")
      @samples[num].parse!
    end
    @samples[num]
  end

  it "should parse title" do
    sample(3).attributes[:title].should == "33rd Floor Bachelor - Stunning Views - 219 Fort York Blvd."
  end

  it "should parse date listed" do
    sample(1).attributes[:posted_at].should == Time.parse("08-Mar-2012")
    sample(2).attributes[:posted_at].should == Time.parse("07-Mar-2012")
  end

  it "should parse date edited" do
    sample(1).attributes[:updated_at].should == Time.parse("08-Mar-2012")
    sample(2).attributes[:updated_at].should be_nil
  end

  it "should parse address" do
    sample(1).attributes[:address][:xstreet0].should == "1268 King St W, Toronto, ON M6K 1G6, Canada"
    sample(2).attributes[:address][:xstreet0].should == "2885 Bayview Ave, Toronto, ON M2K 2S3, Canada"
    sample(4).attributes[:address][:xstreet0].should == "210 Victoria St, Toronto, ON, M5B 2R3"
    sample(5).attributes[:address][:xstreet0].should == "Overture Rd, Toronto, ON M1E, Canada"
  end

  it "should parse price" do
    sample(1).attributes[:price].should == 625
    sample(2).attributes[:price].should == 1200
  end

  it "should parse # bedrooms" do
    sample(1).attributes[:bedrooms].should == 0
  end

  it "should parse phone number" do
    sample(1).attributes[:phone].should == '416-731-9772'
    sample(2).attributes[:phone].should == '647-505-0027'
  end

  it "should parse availability" do
    sample(1).attributes[:available].should == "APRIL 1ST"
    sample(1).attributes[:available_date].should == Date.parse("01-April-2012")

    sample(2).attributes[:available].should be_nil
    sample(2).attributes[:available_date].should be_nil

    sample(3).attributes[:available].should == "May 1st"
    sample(3).attributes[:available_date].should == Date.parse("01-May-2012")

    sample(4).attributes[:available].should == "immediately"

    sample(6).attributes[:available].should == "April 1"

    sample(7).attributes[:available].should == "immediately"

    sample(8).attributes[:available].should == "April"

    sample(9).attributes[:available].should == "2012-04-01 or possibly sooner"
    sample(9).attributes[:available_date].should == Date.parse("01-April-2012")
  end

  it "should parse ensuite landry" do
    sample(1).attributes[:ensuite_landry].should be_false
    sample(2).attributes[:ensuite_landry].should be_true
    sample(3).attributes[:ensuite_landry].should be_true
  end

  it "should parse image urls" do
    sample(1).attributes[:image_urls].should == [
      "http://imgc.classistatic.com/cps/kjc/120308/162r1/687989a_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/162r1/36076n7_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/163r1/4295kc1_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/163r1/1516m3k_20.jpeg",
      "http://imgc.classistatic.com/cps/kjc/120308/164r1/2260hf1_20.jpeg"
    ]

    sample(2).attributes[:image_urls].size.should == 3
  end

 end

