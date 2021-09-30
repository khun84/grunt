require 'rake'
require 'rake/testtask'
require 'yaml'
require "sinatra/activerecord/rake"

# require 'sinatra/activerecord'
# require 'sinatra/activerecord/rake'

# Do test task by default
task :default => [:test]

# All files like "xxx_test.rb" under "test" dir are treated as test files.
Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
end

# A Rails-like interactive console
desc "Enter interactive console"
task "console" do
  system "AWS_PROFILE=daniel-khun irb -r irb/completion -r pp -r ./init"
end
task "c" => :console

task 'environment' do
  require_relative 'init'
end

namespace :es do
  task 'import_pull_requests' => :environment do
    puts ::GitHubWorker.new.perform
  end

  task 'import_admin_log', [:filepaths, :exclude_actions] => :environment do |_t, args|
    files = args[:filepaths].split(' ')
    actions = args[:exclude_actions]&.split(' ') || []
    files.each do |f|
      puts ::AdminLogImporter.run(filepath: f, exclude_actions: actions)
    end
  end

  task 'delete_admin_log' => :environment do
    puts EsClient.get_client(index_name: 'admin_log').delete_index!
  end

  task 'import_business_profile_log', [:filepaths] => :environment do |_t, args|
    files = args[:filepaths].split(' ')
    files.each do |f|
      puts ::BusinessProfileLogImporter.run(filepath: f)
    end
  end

  task 'delete_business_profile_log' => :environment do
    puts EsClient.get_client(index_name: 'admin_log').delete_index!
  end

  task 'import_aasm_log', [:filepaths] => :environment do |_t, args|
    files = args[:filepaths].split(' ')
    files.each do |f|
      puts ::AasmLogImporter.run(filepath: f)
    end
  end

  task 'delete_aasm_log' => :environment do
    puts EsClient.get_client(index_name: 'aasm_log').delete_index!
  end

  task 'import_cache_log', [:filepaths] do |_t, args|
    files = args[:filepaths].split(' ')
    files.each do |f|
      puts ::CacheLogImporter.run(filepath: f)
    end
  end

  task 'delete_cache_log' do
    puts EsClient.get_client(index_name: 'cache_log').delete_index!
  end

  task 'delete_index', [:index_name] do |_t, args|
    idx_name = args[:index_name]
    client = EsClient.get_client(index_name: idx_name)
    raise "Index #{idx_name} not found!" unless client.index_exists?

    puts client.delete_index!
  end

  task 'import_log', [:index_name, :filepaths] do |_t, args|
    idx_name = args[:index_name]
    files = args[:filepaths].split(' ')

    raise 'Index name is missing' unless idx_name
    raise 'File path is missing' unless files.compact.size > 0

    puts ::DefaultLogImporter.run(index_name: idx_name, filepaths: files)
  end
end

namespace :thin do
  task 'start' do
    exec 'thin -d -R config.ru -a 127.0.0.1 -p 8080 -P tmp/pids/thin.pid -l logs/thin.log start'
  end

  task 'restart' do
    exec 'thin -d -R config.ru -a 127.0.0.1 -p 8080 -P tmp/pids/thin.pid -l logs/thin.log restart'
  end

  task 'stop' do
    exec 'thin -R config.ru -a 127.0.0.1 -p 8080 -P tmp/pids/thin.pid -l logs/thin.log stop'
  end
end

def start_sidekiq(**opts)
  opts ||= {}
  daemonize = opts[:daemonize] ? '-d' : ''
  exec "bundle exec sidekiq #{daemonize} -e development -r ./init.rb -C ./config/sidekiq.yml"
end

task :sidekiq_start, [:flags] do |_t, args|
  daemonize = args[:flags]&.split(' ')&.include?('-d')
  puts "Starting sidekiq..."
  start_sidekiq(daemonize: daemonize)
end

def stop_sidekiq(pid_file)
  exec "sidekiqctl stop #{pid_file} 10"
end

def pid_file_exists?(pid_file)
  File.exists?(pid_file)
end

def pid_process_exists?(pid_file)
  pid = File.read(pid_file).gsub("\n", "").to_i
  return false if pid == 0
  !Process.kill(0, pid.to_i).nil?
rescue StandardError
  false
end

task :sidekiq_stop, [:flags] do
  pid_file = 'tmp/pids/sidekiq.pid'
  if pid_file_exists?(pid_file) and pid_process_exists?(pid_file)
    puts "Stopping sidekiq"
    stop_sidekiq(pid_file)
  else
    "Pid or process not found"
  end
end

task :sidekiq_restart do
  Rake::Task['sidekiq_stop'].invoke
  Rake::Task['sidekiq_start'].invoke '-d'
end

namespace :db do
  task 'load_config' do
    require_relative 'init'
    ActiveRecord::Base.configurations = YAML.load_file 'config/database.yml'
  end
end
