class DefaultLogImporter
  attr_reader :es_client, :index_name, :filepaths
  def self.run(args = {})
    new(**args).run
  end

  # @param [Hash] args
  #   @option [Array<String>] filepaths
  #   @option [String] index_name
  def initialize(args = {})
    @filepaths = args[:filepaths].compact
    @index_name = args[:index_name]
    @es_client = EsClient.new(index_name: @index_name)
  end

  def run
    es_client.create_index unless es_client.index_exists?
    import
    es_client.refresh_index
  end

  def import
    filepaths.each do |f|
      raw_payload = []
      total_count = 0
      File.open(f, mode: 'r').each_with_index do |row, idx|
        next if idx == 0
        row = JSON.parse(row)
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
      puts "#{f} done, imported #{total_count} documents"
    end
  end
end
