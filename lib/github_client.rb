class GithubClient
  USERNAME = ::Settings.github.username
  API_KEY = ::Settings.github.api_key
  API_PATH = ::Settings.github.api_path
  SUCCESS_CODES = (200 .. 399)

  attr_reader :title

  def self.run(title: '')
    new(title: title).run
  end

  def initialize(title: '')
    @title = title
  end

  def run
    handle_response(fire_request)
  rescue ::RestClient::ExceptionWithResponse
    null_response
  end

  def fire_request
    ::RestClient::Request.execute(
      method: :get,
      url: API_PATH,
      user: USERNAME,
      password: API_KEY
    )
  end

  def handle_response(response)
    return null_response unless SUCCESS_CODES.include?(response.code)
    payload = safely_parse(response.body)
    # selected_prs = payload.select {|pr| pr['title'] =~ /#{title}/i}
    puts payload.first
    payload.map do |pr|
      pr.slice(
        'url',
        'html_url',
        'number',
        'state',
        'title',
        'created_at',
        'updated_at'
      ).merge(
        base: pr.dig('base', 'ref'),
        user: pr.dig('user', 'login'),
        avatar: pr.dig('user', 'avatar_url'),
        branch: pr.dig('head', 'ref')
      )
    end
  end

  private

  def null_response
    []
  end

  def safely_parse(raw_payload)
    JSON.parse(raw_payload)
  rescue StandardError
    null_response
  end
end
