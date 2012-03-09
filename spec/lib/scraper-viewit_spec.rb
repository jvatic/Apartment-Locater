require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/viewit')

describe Scraper::Viewit do
  def sample(num)
    @samples ||= {}
    unless @samples[num]
      @samples[num] = Scraper::Viewit.new
      @samples[num].doc = Nokogiri::HTML( html_fixture("viewit#{num}") )
      @samples[num].instance_variable_set("@listing_url", "#{num}")
      @samples[num].parse!
    end
    @samples[num]
  end

  it "should parse title" do
    sample(1).attributes[:title].should == "524 Harvie Ave, York, ON : 2 Bedroom for rent -- York Apartments for rent on Viewit.ca - $1025 ViT #71919"
  end

  it "should parse description" do
    sample(1).attributes[:body_html].should == " Newly renovated 2 bedroom apartment in great location of the city. Close to transit and shopping. Allen Road mins away. Laundry facilities on site. Parking available. Call Carlos for details and view...<br><br>www.viewit.ca/71919"
  end

  it "should parse VIT" do
    sample(1).attributes[:viewit_id].should == "71919"
    sample(2).attributes[:viewit_id].should == "57940"
    sample(3).attributes[:viewit_id].should == "121981"
  end

  it "should parse address" do
    sample(1).attributes[:address][:xstreet0].should == "524 Harvie Ave"
    sample(2).attributes[:address][:xstreet0].should == "1887 Queen St. East"
  end

  it "should parse price" do
    sample(1).attributes[:price].should == 1025
    sample(2).attributes[:price].should == 1450
  end

  it "should parse # bedrooms" do
    sample(1).attributes[:bedrooms].should == 2
    sample(2).attributes[:bedrooms].should == 1
  end

  it "should parse phone" do
    sample(1).attributes[:phone].should == "416-678-4449"
    sample(2).attributes[:phone].should == "416-570-8472"
  end

  it "should parse ensuite laundry" do
    sample(1).attributes[:ensuite_landry].should be_false
    sample(2).attributes[:ensuite_landry].should be_true
  end

  it "should parse availability" do
    sample(1).attributes[:available].should be_nil
    sample(1).attributes[:available_date].should be_nil

    sample(2).attributes[:available].should == "April 1st"
    sample(2).attributes[:available_date].should == Date.parse("01-April-2012")
  end

  it "should parse image urls incl floor plan" do
    sample(1).attributes[:image_urls].should == [
      "http://images.viewit.ca/71919/DSC_0029.jpg",
      "http://images.viewit.ca/71919/DSC_0008.jpg",
      "http://images.viewit.ca/71919/DSC_0010.jpg",
      "http://images.viewit.ca/71919/DSC_0007.jpg",
      "http://images.viewit.ca/71919/DSC_0012.jpg",
      "http://images.viewit.ca/71919/DSC_0013.jpg",
      "http://images.viewit.ca/71919/DSC_0004.jpg",
      "http://images.viewit.ca/71919/2BEDPLAN.jpg"
    ]
    sample(2).attributes[:image_urls].size.should == 10
    sample(3).attributes[:image_urls].size.should == 5
  end

end
