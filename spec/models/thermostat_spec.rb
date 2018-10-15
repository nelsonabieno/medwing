require 'rails_helper'

RSpec.describe Thermostat, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it "is valid with all attributes" do
   expect(build(:thermostat)).to be_valid
  end

  it "is invalid without a household_token" do
   expect(build(:thermostat, household_token:nil)).to_not be_valid
  end

  it "is invalid without a location" do
   expect(build(:thermostat, location:nil)).to_not be_valid
  end
end
