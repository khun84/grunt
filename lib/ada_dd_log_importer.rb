class AdaDDLogImporter
  attr_reader :es_client, :filepath, :exclude_actions
  def self.run(args = {})
    new(**args).run
  end

  # @param [Hash] args
  #   @option [String] filepath
  #   @option [Array<String>] exclude_actions
  def initialize(args = {})
    @filepath = args[:filepath]
    @es_client = EsClient.new(index_name: :ada_dd_log)
    @log_names = Array(args[:log_names]).compact
  end

  def run
    es_client.create_index unless es_client.index_exists?
    import
    es_client.refresh_index
  end

  def import
    raw_payload = []
    total_count = 0

    files = if File.directory?(@filepath)
              Dir.glob(File.join(@filepath, '**', '*.json'))
            else
              [@filepath]
            end
    files.each do |f|
      File.open(f, mode: 'r').each_with_index do |row, idx|
        # next if idx == 0
        row = JSON.parse(row)
        next if @log_names.present? && !@log_names.include?(row['filename'])
        attrs = row['attributes'] || {}
        attrs.merge!({
          "_id" => row['_id'],
          "status" => row['status']&.to_s,
        })
        attrs['timestamp'] = attrs['@timestamp']
        attrs['args'] = attrs['args']&.to_json
        attrs['src_file'] = f
        ['params', 'requests', 'error', 'errors', 'status'].each do |k|
          attrs[k] = attrs[k].to_json if attrs.key?(k) && !attrs[k].is_a?(String)
        end

        total_count += 1
        raw_payload.push(attrs)
        if (total_count % Settings.elasticsearch.per_batch) == 0
          puts "----------importing #{raw_payload.size} documents-------------"
          es_client.import(raw_payload, force: false, refresh: false)
          raw_payload = []
        end
      end
    end

    if raw_payload.size > 0
      es_client.import(raw_payload, force: false, refresh: false)
    end
    puts "#{filepath} done, imported #{total_count} documents"
  end
end
