require 'elasticsearch-api'

class EsClient
  include ::Elasticsearch::API::Utils
  attr_reader :index_name, :mapping, :default_mapping
  def self.get_client(**config)
    new(**config)
  end

  def initialize(**config)
    @index_name = config[:index_name]
    @default_mapping = config[:default_mapping]
    @mapping = dispatch_mapping(@index_name)
  end

  def import(payload, force: true, refresh: true)
    es_payload = payload.map { |pr| bulkify(:index, pr) }
    delete_index! if force
    create_index unless index_exists?

    client.bulk body: es_payload
    refresh_index if refresh
  end

  def refresh_index
    client.indices.refresh(index: index_name)
  end

  def create_index
    client.indices.create(index: index_name, body: mapping, include_type_name: true)
  end

  def delete_index!
    return unless index_exists?
    client.indices.delete(index: index_name)
  end

  def index_exists?
    client.indices.exists(index: index_name)
  end

  def search(keyword = nil)
    query = if keyword.blank?
              { match_all: {} }
            else
              {
                bool: {
                  should: [
                    {
                      multi_match: {
                        type: :most_fields,
                        query: keyword,
                        fields: ['base', 'title', 'user'],
                        prefix_length: 3,
                        fuzziness: 2
                      }
                    },
                    {
                      match_phrase_prefix: {
                        user: {
                          query: keyword
                        }
                      }
                    },
                    {
                      match_phrase_prefix: {
                        'number.string': {
                          query: keyword
                        }
                      }
                    }
                  ]
                }
              }
            end

    results = client.search(
      index: :pull_requests,
      type: :doc,
      body: {
        query: query,
        size: 15,
        from: 0
      }
    )
    results.dig('hits', 'hits').map { |hit| hit['_source'] }
  end

  private

  def bulkify(action, data)
    payload = {
      _index: index_name,
      _type: :_doc,
      data: data
    }
    payload['_id'] = data['_id'] if data['_id']
    data.reject! { |k, _| k == '_id' }
    {
      "#{action}": payload
    }
  end

  def dispatch_mapping(index_name)
    return mapping_repo.dispatch_mapping(:default_mappings) if default_mapping
    mapping_repo.dispatch_mapping(index_name)
  end

  def client
    ::ELASTICSEARCH_CLIENT
  end

  def mapping_repo
    ::ElasticsearchMapping
  end
end