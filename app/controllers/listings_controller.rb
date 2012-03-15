class ListingsController < ApplicationController
  def index
    #@location = [-79.377839, 43.649201]
    if params[:filter]
      @longitude = params[:filter][:longitude]
      @latitude  = params[:filter][:latitude]
      @location  = [@longitude, @latitude].compact.map { |i| i.gsub(/[^-\d.]/, '').to_f }
      unless @location.first > -180 && @location.first < 180 && @location.last > -90 && @location.last < 90
        flash[:error] = "Invalid longitude, latitude pair: #{@location.inspect}"
        @location = nil
      end
      @min_price = params[:filter][:min_price]
      @min_price = @min_price.to_f if @min_price
      @max_price = params[:filter][:max_price]
      @max_price = @max_price.to_f if @max_price
      @radius = params[:filter][:radius]
      @radius = @radius.to_f
      @radius = @radius > 0 ? @radius : 10
    end
    @min_price ||= 0
    @max_price ||= 0

    if @location && @location.size == 2
      @listings = Listing.near(@location, @radius, { :units => :km })
    else
      @listings = Listing.all
    end

    if @min_price > 0 && @max_price > 0
      @listings = @listings.where("price.min".to_sym.gte => @min_price, "price.max".to_sym.lte => @max_price)
    elsif @min_price > 0
      @listings = @listings.where("price.min".to_sym.gte => @min_price)
    elsif @max_price > 0
      @listings = @listings.where("price.max".to_sym.lte => @max_price)
    end

    @listings = @listings.clean.order("price.min".to_sym.asc).to_a
    flash[:notice] = "Showing #{@listings.size} listings"
    flash[:notice] << " within #{@radius}km of #{@location.inspect}" if @location && @location.size == 2
  end
end
