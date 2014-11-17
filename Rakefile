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

task default: [:foodcritic, :rubocop, :spec]
