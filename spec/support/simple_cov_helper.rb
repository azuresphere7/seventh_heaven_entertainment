# frozen_string_literal: true

require "simplecov"

SimpleCov.start :rails do
  maximum_coverage_drop 0.5
  minimum_coverage 99.0
  enable_coverage :branch
  primary_coverage :branch

  add_filter "/app/channels"
  add_filter "/app/models/application_record.rb"
  add_filter "/app/mailers/application_mailer.rb"
  add_filter "/app/jobs/application_job.rb"
end
