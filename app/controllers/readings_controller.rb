class ReadingsController < ApplicationController
 skip_before_action :verify_authenticity_token
 before_action :fetch_thermostat
 before_action :validate_params, only: [:create]
 
 #gives the avg, min and max by temerature, humidity and battery_charge for a particular thermostat
 def index
   result = []
   db_data = get_db_aggregation
   redis_cache = get_cache_aggregation

   if redis_cache.empty?
     result = db_data
   elsif db_data.empty?
    result = redis_cache
   else
    db_data.each_with_index do |val,i|
     val.each do |k,value|
       avg_val = (value["avg"].to_f + redis_cache[i][k]["avg"].to_f) / 2
       min_val = [value["min"].to_f, redis_cache[i][k]["min"].to_f].min
       max_val = [value["max"].to_f, redis_cache[i][k]["max"].to_f].max
       result << {k => {"avg" => avg_val, "min" => min_val, "max" =>  max_val} }
     end 
    end
   end

   render json: {thermostat_data: result}
 end

 #returns aggregations(avg,min,max) by temerature, humidity and battery_charge for a particular thermostat within DB
 def get_db_aggregation
   db_data_all = []
   aggregation = @thermostat.readings.pluck('Avg(temperature)', 'Min(temperature)', 'Max(temperature)', 'Avg(humidity)', 'Min(humidity)', 'Max(humidity)', 'Avg(battery_charge)', 'Min(battery_charge)', 'Max(battery_charge)').first
   unless aggregation.empty?
     db_data_all << {"temperature" => {"avg" => aggregation[0].round(2), "min" => aggregation[1], "max" => aggregation[2]}}
     db_data_all << {"humidity" => {"avg" => aggregation[3].round(2), "min" => aggregation[4], "max" => aggregation[5]}}
     db_data_all << {"battery_charge" => {"avg" => aggregation[6].round(2), "min" => aggregation[7], "max" => aggregation[8]}}
   end
   return db_data_all
 end 

 #returns aggregations(avg,min,max) by temerature, humidity and battery_charge for a particular thermostat not in DB i.e cache readings
 def get_cache_aggregation
   redis_data = []
   cache_result = []
   redis_cache = $redis.keys
   unless redis_cache.empty?
     redis_cache.each do |k|
       reading = eval($redis.get(k))
       next if !reading["household_token"].eql?(params[:household_token])
       redis_data << { "temperature" => reading["temperature"], "humidity" => reading["humidity"], "battery_charge" => reading["battery_charge"] }
     end
   end

   unless redis_data.blank?
     thermostat_attr = ["temperature", "humidity", "battery_charge"]
     avg_data = get_avg_data(thermostat_attr, redis_data)
     min_data = get_min_data(thermostat_attr, redis_data)
     max_data = get_max_data(thermostat_attr, redis_data)
     cache_result << {"temperature" => {"avg" => avg_data[0].round(2), "min" => min_data[0], "max" => max_data[0]}}
     cache_result << {"humidity" => {"avg" => avg_data[1].round(2), "min" => min_data[1], "max" => max_data[1]}}
     cache_result << {"battery_charge" => {"avg" => avg_data[2].round(2), "min" => min_data[2], "max" => max_data[2]}}
   end
   return cache_result
 end

 #returns avg by temerature, humidity and battery_charge for a particular thermostat not in DB i.e cache readings
 def get_avg_data(thermostat_attr, redis_data)
   thermostat_attr.map do |type|
     redis_data.map { |x| x[type].to_f }.sum / redis_data.size
   end
 end

 #returns min by temerature, humidity and battery_charge for a particular thermostat not in DB i.e cache readings
 def get_min_data(thermostat_attr, redis_data)
  thermostat_attr.map do |type|
     redis_data.min_by { |h| h[type].to_i }[type]
  end
 end

 #returns max by temerature, humidity and battery_charge for a particular thermostat not in DB i.e cache readings
 def get_max_data(thermostat_attr, redis_data)
   thermostat_attr.map do |type|
     redis_data.max_by { |h| h[type].to_i }[type]
   end
 end

 #creating readings for a particular thermostat
 def create
    reading_id = Reading.generate_id
    params.delete :action
    params.delete :controller
    params.merge!("thermostat_id" => @thermostat.id)
    $redis.set(reading_id, params)
    CreateReadingWorker.perform_async(params, reading_id)
    render json: {reading_id: reading_id}
 end

 #returns thermostat data for a particular reading
 def show
    reading = $redis.get(params[:id]) || Reading.find_by_id(params[:id])
    render :json => { info: "No data for given reading" } and return if reading.nil?
    render json: reading
 end

 private

  def check_params
    params.permit(:thermostat_id, :temperature, :humidity, :battery_charge)
  end

  def fetch_thermostat
    @thermostat = Thermostat.where(household_token: params[:household_token]).first
    render json: { message: 'Unauthorised' }, status: 401 and return if @thermostat.nil?
  end

  #Validating params
  def validate_params
    @reading = Reading.new(check_params)
    if !@reading.valid?
     puts @reading.errors
     render json: { "errors" => @reading.errors } and return
    end
  end
end
