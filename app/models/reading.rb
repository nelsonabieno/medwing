class Reading < ActiveRecord::Base

  validates :battery_charge, :presence => true, :numericality => { :only_integer => true }
  validates :humidity, :presence => true, :numericality => { :only_float => true }
  validates :temperature, :presence => true, :numericality => { :only_float => true }
  belongs_to :thermostat
  after_create :clear_cache 

  #generates unique readings_id_seq
  def self.generate_id 
    Reading.connection.select_value("Select nextval('readings_id_seq')")
  end
 
  #clears cache data once reading created by sidekiq
  def clear_cache
    $redis.del self.id
  end
end
