# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "truncato"
  gem.homepage = "https://github.com/jorgemanrubia/truncato"
  gem.license = "MIT"
  gem.summary = %Q{A tool for truncating HTML strings efficiently}
  gem.description = %Q{Ruby tool for truncating HTML strings keeping a valid HTML markup}
  gem.email = "jorge.manrubia@gmail.com"
  gem.authors = ["Jorge Manrubia"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

$:.unshift File.join(File.dirname(__FILE__), 'benchmark')

require 'nokogiri'
require 'truncato'
require 'truncato_benchmark'

namespace :truncato do
  task :benchmark do
    Truncato::BenchmarkRunner.new.run
  end

  task :vendor_compare do
    Truncato::BenchmarkRunner.new.run_comparison
  end

end
