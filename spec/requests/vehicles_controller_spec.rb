# response.bodyrequire 'rails_helper'
require 'rails_helper'


RSpec.describe Admin::VehiclesController, type: :request do
  let!(:organization1) {create :organization, name: "Burlington High", street: "644 spence street", city: "burlington", zip: "27417"}
  let!(:user) { create :user, organization_id: organization1.id }
  let!(:driver) { FactoryBot.create :driver}
  let!(:driver1) { FactoryBot.create(:driver, first_name: "Frank", organization_id: organization1.id)}
  let!(:vehicle) {FactoryBot.create(:vehicle, driver_id: driver1.id)}
  let!(:vehicle1) {FactoryBot.create(:vehicle, driver_id: driver.id)}

  describe "Create Action" do
    before do
      login_as(user, :scope => :user)
    end

    it "Create a vehicle" do
      expect do
      post admin_driver_vehicles_path(driver1.id), params: {
         vehicle: {
         car_make: "Chevorlet",
         car_model: "Impala",
         car_year: 2010,
         car_state: "NY",
         car_color: "Silver",
         car_plate: "VZW1212",
         insurance_provider: "Geico",
         insurance_start: Date.today,
         insurance_stop: Date.today,
         seat_belt_num: 5
       }
      }
      expect(flash[:notice]).to match("The vehicle information has been created")
      expect(response.redirect?).to eq(true)
      expect(response.redirect?).to redirect_to(admin_driver_path(driver1.id))
      end.to change(Vehicle, :count)
    end

    it "Error when vehicle informations are missing" do
      expect do
      post admin_driver_vehicles_path(driver1.id), params: {
         vehicle: {
         car_make: "Chevorlet",
         car_model: "Impala",
         car_year: 2010,
         car_color: "Silver",
         car_plate: "VZW1212",
       }
      }
      expect(response.body).to include("Seat belt num is not a number")
      expect(response.body).to include("Car state can&#39;t be blank")
      expect(response.body).to include("Seat belt num can&#39;t be blank" )
      expect(response.body).to include("Insurance start can&#39;t be blank")
      expect(response.body).to include("Insurance stop can&#39;t be blank")
      expect(response).to render_template(:edit)
      end.not_to change(Vehicle, :count)
    end


    it "Error when driver belongs to another organization" do
      expect do
      post admin_driver_vehicles_path(driver.id), params: {
         vehicle: {
         car_make: "Chevorlet",
         car_model: "Impala",
         car_year: 2010,
         car_state: "NM",
         car_color: "Silver",
         car_plate: "VZW1212",
         insurance_provider: "Geico",
         insurance_start: Date.today,
         insurance_stop: Date.today,
         seat_belt_num: 5
       }
      }
      expect(flash[:alert]).to match("You cannot create vehicles outside your organization")
      expect(response.redirect?).to eq(true)
      expect(response.redirect?).to redirect_to(admin_driver_path(driver.id))
      end.not_to change(Vehicle, :count)
    end
  end

  describe "New action " do
    before do
      login_as(user, :scope => :user)
    end
    it "render new action" do
    get new_admin_driver_vehicle_path(driver1.id)
    expect(response.redirect?).to eq(false)
    expect(response).to render_template(:new)
    end
  end

  describe "edit action " do
    let!(:vehicle1) {FactoryBot.create(:vehicle, driver_id: driver.id)}
    before do
      login_as(user, :scope => :user)
    end
    it "render edit action" do
    get edit_admin_vehicle_path(vehicle.id)
    expect(response.redirect?).to eq(false)
    expect(response).to render_template(:edit)
    end

    it "Error when driver belongs to another organization" do
    get edit_admin_vehicle_path(vehicle1.id)
    expect(response.redirect?).to eq(true)
    expect(flash[:notice]).to match("You are not authorized to view that vehicle")
    expect(response.redirect?).to redirect_to(admin_drivers_path)
    end
  end

  describe "Update action" do
    before do
      login_as(user, :scope => :user)
    end

    it "Updates a record" do
      expect do
        put admin_vehicle_path(vehicle.id), params: {
          vehicle: {
          car_make: "Toyato",
          car_model: "Camery",
          car_year: 2012,
          car_state: "NE",
          car_color: "Silver",
          car_plate: "VZW1212",
          insurance_provider: "Geico",
          insurance_start: Date.today,
          insurance_stop: Date.today,
          seat_belt_num: 5
          }
        }
        expect(flash[:notice]).to match("The vehicle information has been updated")
        expect(response.redirect?).to eq(true)
        expect(response.redirect?).to redirect_to(admin_driver_path(driver1.id))
      end.not_to change(Vehicle, :count)
    end

    it "Error when vehicle update is missing required information" do
      put admin_vehicle_path(vehicle.id), params: {
        vehicle: {
        car_year: 2019,
        car_color: "Silver",
        car_state: "HI",
        car_plate: "VZW1212",
        insurance_provider: "Geico",
        insurance_start: Date.today - 1.year,
        insurance_stop: Date.today,
        seat_belt_num: "first"
        }
      }
      expect(response.body).to include("Seat belt num is not a number" )
      expect(response.redirect?).to eq(false)
      expect(response).to render_template(:edit)
    end

    it "Error when drivers from another organization" do
      put admin_vehicle_path(vehicle1.id), params: {
        vehicle: {
        car_year: 2019,
        car_color: "Silver",
        car_plate: "VZW1212",
        car_state: "DE",
        insurance_provider: "Geico",
        insurance_start: Date.today - 1.year,
        insurance_stop: Date.today,
        seat_belt_num: 2
        }
      }
      expect(flash[:alert]).to eq("You cannot update vehicles outside your organization")
      expect(response.redirect?).to eq(true)
      expect(response.redirect?).to redirect_to(admin_drivers_path)
    end
  end

  describe "Delete action " do
    before do
      login_as(user, :scope => :user)
    end

    it "Delete a vehicle " do
      delete admin_vehicle_path(vehicle.id)
      expect(response.redirect?).to eq(true)
      expect(Vehicle.count).to eq(1)
      expect(response.redirect?).to redirect_to(admin_driver_path(driver1.id))
    end

    it "Error when driver is from another organization " do
      delete admin_vehicle_path(vehicle1.id)
      expect(response.redirect?).to eq(true)
      expect(flash[:alert]).to eq("You cannot delete vehicles outside your organization")
      expect(Vehicle.count).to eq(2)
      expect(response.redirect?).to redirect_to(admin_drivers_path)
    end

  end

end
