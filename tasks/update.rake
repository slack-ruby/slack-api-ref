require_relative 'lib/slack_api/methods_generator'

namespace :api do
  namespace :methods do
    desc 'Update methods.'
    task :update do
      Rake::Task['api:methods:clean_files'].invoke('methods')
      Rake::Task['api:methods:clean_files'].invoke('groups')
      SlackApi::MethodsGenerator.new.generate!
    end

    desc 'Delete all generated files except undocumented ones.'
    task :clean_files, :dirs do |_t, args|
      raise 'Missing :dirs' unless args[:dirs]

      # keep _undocumented and _patches
      files = Dir["./{#{Array(args[:dirs]).join(',')}}/*"].grep_v(%r{/_\w*\b})
      FileUtils.rm_rf files
    end
  end

  task :update do
    Rake::Task['api:methods:update'].invoke
  end
end
