class GitHubWorker
  include ::Sidekiq::Worker

  def perform
    pull_requests = ::GithubClient.run
    ::EsClient.get_client(index_name: :pull_requests).import(pull_requests)
  end
end
