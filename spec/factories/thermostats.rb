FactoryGirl.define do
  factory :thermostat do
   household_token { SecureRandom.uuid }
   location "Berlin"
  end
end
