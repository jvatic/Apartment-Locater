require File.join( File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe Listing do
  def create_listing(arguments={})
    Listing.create({
     :url            => "http://example.com/somelisting.html",
     :title          => "Example Listing",
     :posted_at      => Time.now,
     :email          => "listinguid@example.com",
     :phone          => "123-443-3432",
     :available      => "March 1st",
     :available_date => Date.strptime("01/03/2012", "%d/%m/%Y"),
     :price          => "3275",
     :square_footage => "700",
     :bedrooms       => 0,
     :ensuite_landry => true,
     :image_urls     => [],
     :address        => "555 something St, City, Provence, Country",
     :body_html      => "<h1>Must have apartment</h1>",
     :duplicate      => false,
     :lat            => 43.6629252,
     :lng            => -79.4661697
    }.merge(arguments))
  end

  before do
    Listing.all.destroy

    # target: { :lat => 43.649201, :lng => -79.377839 }

    @far_listing = create_listing(
      :lat => 49.649301,
      :lng => -89.377939
    )

    @close_listing = create_listing(
      :lat => 43.649301,
      :lng => -79.377939
    )

    @farthest_listing = create_listing(
      :lat => 23.649301,
      :lng => -19.377939
    )
  end

  it "should sort in order of distance from target" do
    sorted = Listing.all.sort
    sorted.first.should == @close_listing
    sorted.last.should == @farthest_listing
  end
end

