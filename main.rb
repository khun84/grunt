require 'sinatra/base'
require 'sinatra/content_for' # For "yield_content" in ERB
require 'sinatra/cross_origin'
require 'fileutils'

class Main < Sinatra::Application
  include ::DateHelper
  # It's for auto reloading the ruby files under your LIB_DIR when you make any
  # changes to them in development mode, so that you don't have to restart your
  # dev server.
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    Dir.glob(File.join(LIB_DIR, '**', '*.rb')) do |file|
      also_reload file
    end
    Dir.glob(File.join(TMP_DIR, '{apis,workers}/**', '*.rb')) do |file|
      also_reload file
    end
  end
  register Sinatra::ActiveRecordExtension
  register Sinatra::CrossOrigin

  options '*' do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept, Origin"
    200
  end

  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
  end

  get '/pull_requests/search' do
    content_type :json
    payload = ::EsClient.get_client(index_name: :pull_requests).search(params[:keyword]).map do |pr|
      pr.merge(since: human_readable_time(Chronic.parse(pr['created_at']), Time.current))
    end
    payload.to_json
  end

  post '/pull_requests/import' do
    content_type :json
    GitHubWorker.new.perform
  end

  post '/admin_logs/import' do
    content_type :json

  end

  post '/chores-bot' do
    content_type :json
    payload = JSON.parse(params[:payload])
    AppLogger.info(payload)
    payments = Payment.last_n_payments
    res_payload = Slack::PaymentSummarySerializer.new(payments).as_json

    begin
      RestClient.post(payload['response_url'], res_payload.to_json)
      {}.to_json
    rescue StandardError => e
      AppLogger.error(request_url: payload['response_url'],err_message: e.message, backtrace: e.backtrace.take(20).join("\n"))
      status 422
    end
  end

  # post '/upload' do
  #   if (tempfile = params[:file][:tempfile]) && (filename = params[:file][:filename])
  #     ext = File.extname(filename)
  #     filename = [File.basename(filename, '.*'), '-', Time.current.strftime('%Y%m%d%H%M%S')].compact.join('')
  #     filename += ext if ext
  #     FileUtils.cp(tempfile.path, File.join('tmp', 'upload', filename))
  #     status 200
  #   else
  #     status 422
  #     body({ message: 'File params is missing.' }.to_json)
  #   end
  # end
  require_relative 'tmp/apis/apis' if File.exists?(File.join(APP_ROOT, 'tmp', 'apis', 'apis.rb'))
end
