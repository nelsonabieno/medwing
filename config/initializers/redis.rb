$redis = Redis::Namespace.new("site_point", :redis => Redis.new)

Sidekiq.configure_server do |config|
 database_url = ENV['DATABASE_URL']
 if(database_url)
   ENV['DATABASE_URL'] = "#{database_url}?pool=5"
   ActiveRecord::Base.establish_connection
  end
end
