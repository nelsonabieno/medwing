require 'rails_helper'

RSpec.describe Reading, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with all attributes" do
   expect(build(:reading)).to be_valid
  end

  it "is invalid without a humidity" do
   expect(build(:reading, humidity:nil)).to_not be_valid
  end
 
  it "is invalid without a temperature" do
   expect(build(:reading, temperature:nil)).to_not be_valid
  end

  it "is invalid without a battery_charge" do
   expect(build(:reading, battery_charge:nil)).to_not be_valid
  end

  it "is invalid if humidity is not a float" do
   expect(build(:reading, humidity: "humidity")).to_not be_valid
  end

  it "is invalid if temperature is not a float" do
   expect(build(:reading, temperature: "temp")).to_not be_valid
  end

  it "is invalid if battery_charge is not a number" do
   expect(build(:reading, battery_charge: "battery")).to_not be_valid
  end
end
