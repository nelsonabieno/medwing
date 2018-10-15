class Thermostat < ActiveRecord::Base
  validates :household_token, :presence => true, :uniqueness => true
  validates :location, :presence => true
  has_many :readings, dependent: :destroy
end
