class Admin::VehiclesController < ApplicationController

  before_action :authenticate_user!

  def new
    @driver = Driver.find(params[:driver_id])
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.driver_id= params[:driver_id]
    driver = Driver.find(params[:driver_id])
    if current_user.organization_id == driver.organization_id
      if @vehicle.save
        flash.notice = "The vehicle information has been created"
        redirect_to admin_driver_path(params[:driver_id])
      else
        # The form is handling the errors. Turned of flash alerts error
        # flash.alert = @vehicle.errors.full_messages.to_sentence
        @driver =  Driver.find(params[:driver_id])
        render "edit"
      end
    else
      flash.alert = "You cannot create vehicles outside your organization"
      redirect_to admin_driver_path(params[:driver_id])
    end

  end

  def edit
    @vehicle = Vehicle.find(params[:id])
    @driver = Driver.find(@vehicle.driver_id)
    if current_user.organization_id != @vehicle.driver.organization_id
      flash.notice = "You are not authorized to view that vehicle"
      redirect_to admin_drivers_path
    end
  end

  def update
    @vehicle = Vehicle.find(params[:id])
    @driver = @vehicle.driver
      if current_user.organization_id == @vehicle.driver.organization_id
        if @vehicle.update(vehicle_params)
          flash.notice = "The vehicle information has been updated"
          redirect_to admin_driver_path(@vehicle.driver_id)
        else
          # The form is handling the errors. Turned of flash alerts error
          # flash.alert = @vehicle.errors.full_messages.to_sentence
          render "edit"
        end
      else
        flash.alert = "You cannot update vehicles outside your organization"
        redirect_to admin_drivers_path
      end
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    if current_user.organization_id == @vehicle.driver.organization_id
      @vehicle.destroy
      redirect_to admin_driver_path(@vehicle.driver_id)
    else
      flash.alert = "You cannot delete vehicles outside your organization"
      redirect_to admin_drivers_path
    end
  end

  private
  def vehicle_params
    params.require(:vehicle).permit(:car_make, :car_model,
       :car_color, :car_year,:car_plate, :car_state, :seat_belt_num, :insurance_provider,
     :insurance_start, :insurance_stop, :image)
  end
end
