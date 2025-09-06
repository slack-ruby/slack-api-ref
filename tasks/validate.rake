require_relative 'lib/slack_api/spec_validator'

namespace :api do
  desc 'Validate scraped methods and events are valid.'
  task :validate do
    Rake::Task['api:methods:validate'].invoke
    Rake::Task['api:events:validate'].invoke
  end
end