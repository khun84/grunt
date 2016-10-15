class ElasticsearchMapping
  MAPPINGS = YAML.load_file(File.join(::CFG_DIR, 'elasticsearch_mappings.yml')).symbolize_keys

  def self.dispatch_mapping(key)
    MAPPINGS[key]
  end
end
