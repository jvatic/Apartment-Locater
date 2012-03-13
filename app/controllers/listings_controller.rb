class ListingsController < ApplicationController
  def index
    @location = [-79.377839, 43.649201]
    @listings = Listing.near(@location, 1, { :units => :km }).clean.order(:price.asc).to_a
    flash[:notice] = "Showing #{@listings.size} listings within 1km of #{@location.inspect}"
  end
end
