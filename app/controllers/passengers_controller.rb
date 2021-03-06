class PassengersController < ApplicationController
  def index
    @passengers = Passenger.all
  end

  def show
    @passenger = Passenger.find_by(id: params[:id])
    if @passenger.nil? || !(@passenger.isactive)
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    end
  end

  def new
    @passenger = Passenger.new
  end

  def create
    @passenger = Passenger.new(passenger_params)
    if @passenger.save
      redirect_to passenger_path(id: @passenger[:id])
      return
    else
      render :new, status: :bad_request 
      return
    end
  end

  def edit
    @passenger = Passenger.find_by(id: params[:id])
    if @passenger.nil?
      redirect_to passengers_path
      return
    elsif !(@passenger.isactive)
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    end
  end

  def update
    @passenger = Passenger.find_by(id: params[:id])
    if @passenger.nil? || !(@passenger.isactive)
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    elsif @passenger.update(passenger_params)
      redirect_to passenger_path(id: @passenger[:id])
      return
    else
      render :edit, status: :bad_request  
      return
    end
  end

  def destroy
    @passenger = Passenger.find_by(id: params[:id])
    if @passenger.nil? || !(@passenger.isactive)
      render :file => "#{Rails.root}/public/404.html",  layout: false, status: :not_found
      return
    else
      @passenger.update(isactive: false)
      redirect_to passengers_path
      return
    end
  end

  private

  def passenger_params
    return params.require(:passenger).permit(:name, :phone_num)
  end
end
