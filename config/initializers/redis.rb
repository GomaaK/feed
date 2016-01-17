location = Rails.application.secrets.redis_url
uri = URI.parse(location)
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => Rails.application.secrets.redis_password)



Sidekiq.configure_server do |config|
  config.redis = { 
    :url => location,
    :password => Rails.application.secrets.redis_password,
    :size => 6
   }
end

Sidekiq.configure_client do |config|
  config.redis = { 
    :url => location,
    :password => Rails.application.secrets.redis_password,
    :size => 6
   }
end