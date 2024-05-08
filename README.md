# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

## Dependencies
- ruby 3.2.1
- rails 7.1.3
- redis
- postgres

## Setup
```
bundle install
```

setup the db and load the seeds

```
bundle exec rails db:setup
```

Run the testsuite with documentation
```
bundle exec rspec -fd
```

or start the webserver and sidekiq
```
foreman start
```