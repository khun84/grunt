# Description

**grunt** is an application to perform grunt work that can be delegated to a machine.
Its consist of
1. a Sinatra app, which runs on a **thin** server, with actions exposed as api and
2. a collection of rake tasks that can be invoked in case you do not want to run the app server

See `main.rb` and `Rakefile` for the usage of the action api and rake task.

# Dependency

1. Elasticsearch >= 7.0

# Tutorial

1. To start the server, run `rake thin:start`
2. To restart the server, run `rake thin:restart`
