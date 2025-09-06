require_relative 'lib/slack_api/methods_generator'

namespace :api do
  namespace :methods do
    desc 'Update methods.'
    task :update do
      SlackApi::MethodsGenerator.new.generate!
    end
  end

  task :update do
    Rake::Task['api:methods:update'].invoke
  end
end
