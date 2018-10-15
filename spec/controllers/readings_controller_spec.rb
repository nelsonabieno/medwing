require 'rails_helper'

RSpec.describe ReadingsController, type: :controller do
   thermostat = FactoryGirl.create(:thermostat)
   reading = FactoryGirl.create(:reading, :thermostat_id => thermostat.id)
   it "renders the #index action success" do
    get :index, household_token: thermostat.household_token
    expect(response).to be_success
    expect(response.content_type).to eq('application/json')
  end

  it "creates a reading for a particular thermostat" do
    post :create, "household_token"=>"IXBLUAKN", "temperature"=>"55.4", "humidity"=>"28", "battery_charge"=>"1450"
    expect(response).to be_success
  end
 
  it "renders a reading for a particular thermostat" do
    get :show, "household_token"=>thermostat.household_token, "id" => reading.id
    expect(response).to be_success
  end

  it "#show renders Unauthorised message without household_token" do
    get :show, "id" => reading.id
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["message"]).to eq("Unauthorised")
  end

  it "#create renders Unauthorised message without household_token" do
    post :create, "temperature"=>"55.4", "humidity"=>"28", "battery_charge"=>"1450"
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["message"]).to eq("Unauthorised")
  end

  it "#index renders Unauthorised message without household_token" do
    get :index
    parsed_response = JSON.parse(response.body)
    expect(parsed_response["message"]).to eq("Unauthorised")
  end
end
