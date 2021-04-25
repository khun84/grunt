require 'shoryuken'
Shoryuken::Logging.logger = LogStashLogger.new(type: :stdout)
Shoryuken.cache_visibility_timeout = true
