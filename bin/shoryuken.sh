#!/usr/local/bin/bash

AWS_PROFILE=daniel-khun /Users/Daniel/.rvm/bin/rvm `cat /Users/Daniel/RubymineProjects/grunt/.ruby-version` do bundle exec shoryuken start --require ./init.rb -C ./config/shoryuken.yml
