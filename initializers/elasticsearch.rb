require 'elasticsearch/model'

logger = Logger.new('log/elasticsearch.log')
logger.formatter = proc do |_, _, _, msg|
  "#{msg}\n"
end
ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(
  host: Settings.elasticsearch.host,
  port: Settings.elasticsearch.port,
  request_timeout: Settings.elasticsearch.request_timeout,
  logger: logger
)
