$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'bundler'
require 'nokogiri'
require 'truncato'
require 'html_truncator'
require 'peppercorn'
require 'benchmark'

Bundler.setup
Bundler.require

Dir[File.dirname(__FILE__) + '/truncato/**/*.rb'].each do |file|
  load file
end


