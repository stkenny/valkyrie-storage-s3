# frozen_string_literal: true
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task(:default).clear
task default: [:ci]

if defined? RSpec
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end

desc 'Run RuboCop style checker'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop-rspec'
  task.fail_on_error = true
end

task :ci do
  Rake::Task[:rubocop].invoke
  Rake::Task[:spec].invoke
end
