Time.zone = TZ
ActiveRecord::Base.time_zone_aware_attributes = true
AppLogger = LogStashLogger.new(type: :file, path: 'log/web.log', sync: true)
