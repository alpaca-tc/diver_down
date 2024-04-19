# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rake/extensiontask'
task(build: :compile)

Rake::ExtensionTask.new('diver_down') do
  _1.name = 'diver_down_ext'
  _1.lib_dir = 'lib/diver_down'
end

Rake::ExtensionTask.new('diver_down/trace') do
  _1.name = 'diver_down_trace_ext'
  _1.lib_dir = 'lib/diver_down/trace'
end

task default: %i[spec rubocop]
