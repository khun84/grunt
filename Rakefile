require_relative 'init'
require 'rake/testtask'
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
    system "irb -r irb/completion -r ./lib/console.rb"
end

namespace :es do
  task 'import_pull_requests' do
    puts ::GitHubWorker.new.perform
  end

  task 'import_admin_log', [:filepaths, :exclude_actions] do |_t, args|
    files = args[:filepaths].split(' ')
    actions = args[:exclude_actions]&.split(' ') || []
    files.each do |f|
      puts ::AdminLogImporter.run(filepath: f, exclude_actions: actions)
    end
  end

  task 'delete_admin_log' do
    puts EsClient.get_client(index_name: 'admin_log').delete_index!
  end

  task 'import_business_profile_log', [:filepaths] do |_t, args|
    files = args[:filepaths].split(' ')
    files.each do |f|
      puts ::BusinessProfileLogImporter.run(filepath: f)
    end
  end

  task 'delete_business_profile_log' do
    puts EsClient.get_client(index_name: 'admin_log').delete_index!
  end

  task 'import_aasm_log', [:filepaths] do |_t, args|
    files = args[:filepaths].split(' ')
    files.each do |f|
      puts ::AasmLogImporter.run(filepath: f)
    end
  end

  task 'delete_aasm_log' do
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
