# frozen_string_literal: true

class AdminRideController < ApplicationController
  RIDES_PER_PAGE_AMOUNT = 10
  before_action :authenticate_user!
  before_action :conditional_ride_reason, only: [:create, :update]
  #  before_action :rider_is_active, only: :create
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  layout 'administration'

  def new
    @ride = Ride.new
  end

  def show
    begin
    @ride = Ride.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "Record not found."
      redirect_to admin_ride_index_path
      return
    end
    @second_ride = Ride.find(@ride.return) if @ride.return
    authorize @ride
  end

  def index
    if params[:status].present?
      @rides = Ride.status(params[:status]).where("organization_id =? AND pick_up_time >=?", current_user.organization.id, Date.today)
    else
      @rides = Ride.select("rides.*,riders.first_name,riders.last_name").joins(:rider).where("rides.organization_id =? AND pick_up_time >= ?", current_user.organization.id, Date.today)
    end
    @query = @rides.ransack(params[:q])
    @search = Kaminari.paginate_array(@query.result).page(params[:page]).per(RIDES_PER_PAGE_AMOUNT)
  end

  def edit
    begin
    @ride = Ride.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "Record not found."
      redirect_to admin_ride_index_path
      return
    end
    if @ride.outbound
      @ride = Ride.find(@ride.outbound)
    end
    authorize @ride
  end

  def create
    begin
      rider = Rider.find(ride_params[:rider_id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "The rider can't be blank."
      @ride = Ride.new
      render 'new'
      return
    end
    authorize rider
    keep_proccessing = rider_is_active
    if !keep_proccessing
      return
    end
    organization = Organization.find(current_user.organization_id)
    if organization.use_tokens == true
      token = rider.next_valid_token
      token = rider.valid_tokens.create if token.nil?
    end
    @start_location = Location.new(street: ride_params[:start_street],
                                   city: ride_params[:start_city],
                                   state: ride_params[:start_state],
                                   zip: ride_params[:start_zip])
    @end_location = Location.new(street: ride_params[:end_street],
                                 city: ride_params[:end_city],
                                 state: ride_params[:end_state],
                                 zip: ride_params[:end_zip])

    @ride = Ride.new(organization_id: current_user.organization_id,
                     rider_id: rider.id,
                     driver_id: ride_params[:driver_id],
                     pick_up_time: ride_params[:pick_up_time],
                     reason: @reason,
                     round_trip: ride_params[:round_trip],
                     notes: ride_params[:notes])
    if @ride.round_trip
      @second_ride = Ride.new(organization_id: current_user.organization_id,
                              rider_id: rider.id,
                              driver_id: ride_params[:second_driver_id],
                              pick_up_time: ride_params[:return_pick_up_time],
                              reason: @reason,
                              round_trip: false,
                              notes: ride_params[:notes])
    end
    if !return_pick_up_time_not_in_past
      return
    end
    location = save_location_error_handler(@start_location)
    if location.nil?
      flash.now[:error] = @start_location.errors.full_messages.join("\n")
      render 'new'
      return
    else
      @start_location = location
    end
    location = save_location_error_handler(@end_location)
    if location.nil?
      flash.now[:error] = @end_location.errors.full_messages.join("\n")
      render 'new'
      return
    else
      @end_location = location
    end
    @ride.start_location_id = @start_location.id
    @ride.end_location_id = @end_location.id
    round_trip_save
    if !locations_can_not_be_the_same
      return
    end
    when_ride_driver_is_assigned_change_status
    if @ride.save || @second_ride.save
      return unless round_trip_save
      rider_choose_save_location
      only_15_location_saves(organization)
      if organization.use_tokens == true
        token.ride_id = @ride.id
        token.save
      end
      flash[:notice] = "Ride created for #{rider.full_name}"
      redirect_to admin_ride_path(@ride)
      return
    else
      flash.now[:error] = @ride.errors.full_messages.join("\n")
      render 'new'
      return
    end
  end

  def update
    @ride = Ride.find(params[:id])
    authorize @ride
    @start_location = @ride.start_location
    @end_location = @ride.end_location
    organization = Organization.find(current_user.organization_id)
    @start_location = Location.new(street: ride_params[:start_street],
                                   city: ride_params[:start_city],
                                   state: ride_params[:start_state],
                                   zip: ride_params[:start_zip])
    location = save_location_error_handler(@start_location)
    if location.nil?
      flash.now[:error] = @start_location.errors.full_messages.join("\n")
      @ride = Ride.find(params[:id])
      render 'edit'
      return
    else
      location = @start_location
    end
    @end_location = Location.new(street: ride_params[:end_street],
                                 city: ride_params[:end_city],
                                 state: ride_params[:end_state],
                                 zip: ride_params[:end_zip])
    location = save_location_error_handler(@end_location)
    if location.nil?
      flash.now[:error] = @end_location.errors.full_messages.join("\n")
      @ride = Ride.find(params[:id])
      render 'edit'
      return
    else
      location = @end_location
    end
    rider_choose_save_location
    only_15_location_saves(organization)
    if @ride.update(
      organization_id: current_user.organization_id,
      rider_id: ride_params[:rider_id],
      driver_id: ride_params[:driver_id],
      pick_up_time: ride_params[:pick_up_time],
      reason: @reason,
      round_trip: ride_params[:round_trip],
      notes: ride_params[:notes],
      start_location: @start_location,
      end_location: @end_location
    )
    else
      render "edit"
      return
    end
    round_trip_false

    if @ride.round_trip
      if @ride.return
        @second_ride = Ride.find(@ride.return)
        @second_ride.update(
          organization_id: current_user.organization_id,
          rider_id: ride_params[:rider_id],
          driver_id: params[:second_ride][:second_driver_id],
          pick_up_time: ride_params[:return_pick_up_time],
          reason: @reason,
          round_trip: false,
          notes: ride_params[:notes],
          start_location: @start_location,
          end_location: @end_location
        )
      else
        @second_ride = Ride.find_or_create_by(organization_id: current_user.organization_id,
                                              rider_id: @ride.rider_id,
                                              driver_id: ride_params[:second_driver_id],
                                              pick_up_time: ride_params[:return_pick_up_time],
                                              reason: @ride.reason,
                                              round_trip: false,
                                              start_location: @start_location,
                                              end_location: @end_location)
      end
      if !return_pick_up_time_not_in_past
        return
      end
      return unless round_trip_save
    end
    if !locations_can_not_be_the_same
      return
    end
    when_ride_driver_is_assigned_change_status
    if @ride.save 
      rider_choose_save_location
      flash.notice = 'The ride information has been updated.'
      redirect_to admin_ride_path(@ride)
    end
  end

  def approve
    @ride = Ride.find(params[:id])
    authorize @ride
    @ride.update_attributes(status: 'approved')
    flash.notice = 'Ride approved.'
    redirect_to request.referrer || admin_ride_index_path
  end

  private

  def ride_params
    params.require(:ride).permit(:rider_id, :driver_id, :pick_up_time, :save_start_location, :save_end_location,
                                 :organization_rider_start_location, :start_street, :start_city, :start_state, :start_zip,
                                 :organization_rider_end_location, :end_street, :end_city, :end_state, :end_zip, :reason,
                                 :status, :q, :round_trip, :second_driver_id, :return_pick_up_time, :notes, :other_reason)
  end

  # TODO: -- possibly clean out old record, and make a plan to fix it in the future.
  def save_location_error_handler(location)
    @old_location = Location.new(street: location.street, city: location.city, state: location.state, zip: location.zip)
    return nil unless location.validate
    if @old_location.street != location.street || @old_location.city != location.city || @old_location.state != location.state || @old_location.zip != location.zip
      flash[:alert] = " We updated the original address you entered: #{@old_location.full_address}. You can see the updated address in the ride details."
    end
    l_new = location.save_or_touch
    l_new
  end


  def when_ride_driver_is_assigned_change_status
    if !@ride.driver_id.nil?
      @ride.status = "scheduled"
    else
      @ride.status = "approved"
    end

    if @ride.round_trip
      if !@second_ride.driver_id.nil?
        @second_ride.status = "scheduled"
      else
        @second_ride.status = "approved"
      end
    else
      return false
    end
    
  end

  def rider_choose_save_location
    if ride_params[:save_start_location] == 'saved'
      lr1 = LocationRelationship.new(location_id: @ride.start_location.id, organization_id: current_user.organization.id)
      lr1.save_or_touch
    end
    if ride_params[:save_end_location] == 'saved'
      lr2 = LocationRelationship.new(location_id: @ride.end_location.id, organization_id: current_user.organization.id)
      lr2.save_or_touch
    end
  end

  def locations_can_not_be_the_same
    if @ride.start_location.full_address == @ride.end_location.full_address
      flash.now[:alert] = "Start location and end location can not be the same"
      if @ride.id
        render "edit"
        return false
      else
        render "new"
        return false
      end
    else
      return true
    end
  end

  def round_trip_save
    if @ride.round_trip
      @second_ride.outbound = @ride.id
      @second_ride.start_location_id = @end_location.id
      @second_ride.end_location_id = @start_location.id
      unless @second_ride.save
        flash.now[:error] = @second_ride.errors.full_messages.join("\n")
        render 'new'
        return false
      end
      @ride.update(return: @second_ride.id)
    end
    true
  end

  def round_trip_false
    if !@ride.round_trip and @ride.return
       Ride.find(@ride.return).destroy
      @ride.update(return: nil)
    end
  end

  def return_pick_up_time_not_in_past
    if @ride.round_trip
      if @second_ride.pick_up_time < @ride.pick_up_time + 30.minutes
        flash.now[:alert] = "Return time must be at least 30 minutes after departure time"
        if @ride.id
          render "edit"
          return false
        else
          render "new"
          return false
        end
      else
        return true
      end
    end
    return true
  end

  def only_15_location_saves(organization)
    if (ride_params[:save_start_location] == 'saved') || (ride_params[:save_end_location] == 'saved')
      org_lrs = organization.location_relationships.order(updated_at: :desc)
      if org_lrs.count > 15
        (15..org_lrs.count - 1).each do |i|
          org_lrs[i].destroy
        end
      end
    end
  end

  def user_not_authorized
    flash.notice = 'You are not authorized to view this information'
    redirect_to admin_ride_index_url
  end

  def rider_is_active
    rider = Rider.find(params[:ride][:rider_id])
    unless rider.is_active?
      flash.alert = 'The rider is deactivated.'
      redirect_to admin_ride_index_path
      return false
    end
    return true
  end

  def conditional_ride_reason
    if ride_params[:reason] == 'Other'
      @reason = ride_params[:other_reason]
    else
      @reason = ride_params[:reason]
    end
  end
end
