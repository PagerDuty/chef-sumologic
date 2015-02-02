require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'foodcritic'

desc 'Run all linters on the codebase'
task :linters do
  Rake::Task['foodcritic'].invoke
  Rake::Task['rubocop'].invoke
end

desc "Run spec tests on the codebase"
task :spec do
  Rake::Task['spec'].invoke
end

desc 'Run all test kitchen combinations on the codebase'
task :kitchen do
  Rake::Task['berkshelf'].invoke
  Rake::Task['kitchen:all'].invoke
end

desc 'Run foodcritic on all cookbooks'
FoodCritic::Rake::LintTask.new do |t|
  t.options = {
    fail_tags: ['any'],
    tags: ['~solo', '~readme', '~FC023']
  }
end


desc 'rubocop compliancy checks'
RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = %w{ */*.rb }
  t.fail_on_error = true
end

desc 'Run sepc tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--profile"
  t.pattern = %w{ spec/*.rb }
  t.fail_on_error = true
end

desc 'Install berkshelf cookbooks locally'
task :berkshelf do |t, args|
  require 'berkshelf'
  require 'berkshelf/berksfile'
  current_dir = File.expand_path('../', __FILE__)
  berksfile_path = File.join(current_dir, 'Berksfile')
  cookbooks_path = File.join(current_dir, 'cookbooks')
  berksfile = Berkshelf::Berksfile.from_file(berksfile_path)
  FileUtils.rm_rf(cookbooks_path)
  berksfile.vendor(cookbooks_path)
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end

task default: [:foodcritic, :rubocop, :spec]
