require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')
require File.join( File.dirname(File.expand_path(__FILE__)), '..', '..', 'lib/scraper/bedbug_registry')

describe Scraper::BedbugRegistry do
  def sample(num)
    @samples ||= {}
    unless @samples[num]
      @samples[num] = Scraper::BedbugRegistry.new
      @samples[num].doc = Nokogiri::HTML( html_fixture("bedbug_registry#{num}") )
      @samples[num].instance_variable_set("@listing_url", "#{num}")
      @samples[num].parse!
    end
    @samples[num]
  end

  it "should detect infested result" do
    sample(1).infested?.should be_true
  end

  it "should detect clear result" do
    sample(2).infested?.should be_false
  end

  it "should detect no result as clear result" do
    sample(3).infested?.should be_false
  end

  context "#address_url" do
    it "should convert address into search url" do
      address = "218 Queen St E, Toronto, ON M5A, Canada"
      Scraper::BedbugRegistry.address_url(address).should == "http://www.bedbugregistry.com/search/a:218-Queen-St-E/l:Toronto-ON/"

      address = "234 Rideau St, Ottawa, ON K1M 0A9, Canada"
      Scraper::BedbugRegistry.address_url(address).should == "http://www.bedbugregistry.com/search/a:234-Rideau-St/l:Ottawa-ON/"
    end

    it "should return nil for non-street addresses" do
      address = "Carlton St & Bleecker St, Toronto, ON M5A, Canada"
      Scraper::BedbugRegistry.address_url(address).should be_nil
    end
  end
end
