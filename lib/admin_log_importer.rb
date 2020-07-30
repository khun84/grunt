class AdminLogImporter
  attr_reader :es_client, :filepath, :exclude_actions
  def self.run(args = {})
    new(**args).run
  end

  # @param [Hash] args
  #   @option [String] filepath
  #   @option [Array<String>] exclude_actions
  def initialize(args = {})
    @filepath = args[:filepath]
    @exclude_actions = Array(args[:exclude_actions])
    @es_client = EsClient.new(index_name: :admin_log)
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
      next if row['action'].in?(exclude_actions)
      row['timestamp'] = row['@timestamp']
      row['params'] = row['params'].to_json

      total_count += 1
      raw_payload.push(row)
      if (total_count % 50) == 0
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
end
