# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "truncato/version"

Gem::Specification.new do |s|
  s.name = "truncato"
  s.version = Truncato::VERSION

  s.authors = ["Jorge Manrubia"]
  s.date = "2013-09-10"
  s.description = "Ruby tool for truncating HTML strings keeping a valid HTML markup"
  s.email = "jorge.manrubia@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE.txt", "Rakefile", "README.rdoc"]
  s.homepage = "https://github.com/jorgemanrubia/truncato"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.2"
  s.summary = "A tool for truncating HTML strings efficiently"

  s.add_dependency "nokogiri", ">= 1.7.0", "~> 1.8.0"
  s.add_dependency "htmlentities", "~> 4.3.1"

  s.add_development_dependency "rspec", '~> 2.14.1'
  s.add_development_dependency "rake", '~> 10.1.1'
end

