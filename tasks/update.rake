namespace :api do
  desc 'Delete all generated files except undocumented ones.'
  task :clean_files, :dirs do |_t, args|
    raise 'Missing :dirs' unless args[:dirs]

    # keep _undocumented and _patches
    files = Dir["./{#{Array(args[:dirs]).join(',')}}/*"].grep_v(%r{/_\w*\b})
    FileUtils.rm_rf files
  end

  task :update do
    Rake::Task['api:methods:update'].invoke
    Rake::Task['api:events:update'].invoke
  end
end
