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

# Using Docker
## Run Rake Task for Log Parsing
Log parser sends logs to Elasticsearch for analytics. There are three ways to run log parser rake task.
1. Send logs to an Elasticsearch cluster running on localhost.
2. Send logs to a single node Elasticsearch cluster running on Docker.
3. Send logs to a three node Elasticsearch cluster running on Docker.

### Local ES
- Start:
`docker-compose up -d`
- Exec to Container:
`docker-compose exec grunt sh`
- Stop:
`docker-compose down`
### Single Node ES
- Start:
`docker-compose -f docker-compose.es.yml up -d`
- Exec to Container:
`docker-compose -f docker-compose.es.yml exec grunt sh`
- Stop:
`docker-compose -f docker-compose.es.yml down`
### Three Node ES
- Start:
`docker-compose -f docker-compose.escluster.yml up -d`
- Exec to Container:
`docker-compose -f docker-compose.escluster.yml exec grunt sh`
- Stop:
`docker-compose -f docker-compose.escluster.yml down`

## Settings
In `config/settings.yml` use the following settings for connecting to Elasticsearch when running from Docker.
### Using Local ES
```
elasticsearch:
  host: host.docker.internal
  port: 9200
```

### Using Docker ES
```
elasticsearch:
  host: es
  port: 9200
```

## Command for Rake Task
Download logs from S3 using the script in `fetchs3logs.sh`.
Set the values for `BUCKET`, `LOG_TYPE` and `LOG_FILE_PREFIX`.
Put log files in a folder inside this repository.
This repository will be mounted inside container in the folder `/app`.

Command is as follows:

`bundle exec rake es:import_admin_log['/app/absolute/path/to/logfile.log']`

## View logs using Kibana
Kibana will be running on [localhost:5601](http://localhost:5601)
