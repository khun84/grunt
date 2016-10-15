class AdminLogImporter
  attr_reader :es_client, :filepath
  def self.run(args= {})
    new(**args).run
  end

  def initialize(filepath:)
    @filepath = filepath
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
      total_count += 1
      row = JSON.parse(row)
      row['timestamp'] = row['@timestamp']
      row['params'] = row['params'].to_json
      raw_payload.push(row)
      if (idx % 50) == 0
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
