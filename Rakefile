# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rake/extensiontask'
task(build: :compile)

Rake::ExtensionTask.new('diver_down/trace') do
  _1.lib_dir = 'lib/diver_down'
end

task default: %i[spec rubocop]
