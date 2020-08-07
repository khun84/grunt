require 'base64'

class AasmLogImporter
  attr_reader :es_client, :filepath
  def self.run(args = {})
    new(**args).run
  end

  # @param [Hash] args
  #   @option [String] filepath
  def initialize(args = {})
    @filepath = args[:filepath]
    @es_client = EsClient.new(index_name: :aasm_log)
  end

  def run
    es_client.create_index unless es_client.index_exists?
    import
    es_client.refresh_index
  end

  def import
    raw_payload = []
    total_count = 0

    File.open(filepath, mode: 'r').each_with_index do |row, idx|
      next if idx == 0
      row = JSON.parse(row)
      row['timestamp'] = row['@timestamp']
      row['country'] = row['apartment']
      row.reject! { |k, _| k == '@timestamp' || k == 'apartment' }

      row['_id'] = generate_id(row['event'], row['timestamp'], row['country'])
      total_count += 1
      raw_payload.push(row)
      if (total_count % Settings.elasticsearch.per_batch) == 0
        puts "----------importing #{raw_payload.size} documents-------------"
        es_client.import(raw_payload, force: false, refresh: false)
        raw_payload = []
      end
    end

    if raw_payload.size > 0
      es_client.import(raw_payload, force: false, refresh: false)
    end
    puts "#{filepath} done, imported #{total_count} documents"
  end

  private

  def generate_id(*args)
    Base64.strict_encode64(args.join('|'))
  end
end
