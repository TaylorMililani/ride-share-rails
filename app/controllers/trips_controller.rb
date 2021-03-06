class TripsController < ApplicationController

  def index
    if params[:passenger_id]
      passenger = Passenger.find_by(id: params[:passenger_id])
      @trips = passenger.trips
    elsif params[:driver_id]
      driver = Driver.find_by(id: params[:driver_id])
      @trips = driver.trips
    else
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
    end
  end

  def show
    @trip = Trip.find_by(id: params[:id])
    if @trip.nil?
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    end
  end

  def new
    @trip = Trip.new
  end

  def create
    @drivers = Driver.all

    available_driver = nil
    @drivers.each do |driver|
      if driver.available == true
        break if available_driver = driver
      end
    end

    if available_driver.nil?
      redirect_to passenger_path(params[:passenger_id]), notice: "No driver is available now, please try again later."
      return
    end

    if params[:passenger_id]
      passenger = Passenger.find_by(id: params[:passenger_id])
      if passenger.nil?
        render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
        return
      else
        pass_id = passenger.id
      end
    end

    @trip = Trip.new(date: Time.now.strftime("%Y-%m-%d"), rating: nil, cost: rand(1000..3500), driver_id: available_driver.id, passenger_id: pass_id, complete: false)

    if @trip.save
      available_driver.update(available: false)
      redirect_to passenger_path(params[:passenger_id])
      return
    else
      redirect_to passenger_path(params[:passenger_id])
      return
    end
  end

  def edit
    @trip = Trip.find_by(id: params[:id])
    if @trip.nil?
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    end
  end

  def update
    @trip = Trip.find_by(id: params[:id])
    if @trip.nil?
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    elsif @trip.update(trip_params)
      redirect_to trip_path(id: @trip[:id])
      return
    else
      render :edit, status: :bad_request  
      return
    end
  end

  def destroy
    @trip = Trip.find_by(id: params[:id])
    if @trip.nil?
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    end

    driver = @trip.driver
    passenger = @trip.passenger
    if !(driver.isactive) && !(passenger.isactive)
      @trip.destroy
      redirect_to root_path  # should we have index page?
      return
    else
      redirect_to trip_path(@trip.id), notice: "Either Driver or Passenger is still active, couldn't delete the trip."
      return
    end
  end

  def complete_trip
    @trip = Trip.find_by(id: params[:id])
    if @trip.complete == false
      @driver = Driver.find_by(id: @trip.driver_id)
      @trip.update(complete: true)
      @driver.update(available: true)
      redirect_to trip_path(@trip.id)
    end
    return
  end

  private

  def trip_params
    return params.require(:trip).permit(:date, :rating, :cost)
  end
end
