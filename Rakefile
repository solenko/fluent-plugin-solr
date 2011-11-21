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
  gem.name = "fluent-plugin-solr"
  gem.homepage = "http://github.com/btigit/fluent-plugin-solr"
  gem.license = "MIT"
  gem.summary = "Solr output plugin for Fluent event collector"
  gem.description = "Solr output plugin for Fluent event collector"
  gem.email = "nakazawa.nobutaka@brains-tech.co.jp"
  gem.authors = ["Nobutaka Nakazawa"]
  gem.version = '0.1.0'
  gem.add_dependency("fluentd", "~> 0.10.0")
  gem.add_dependency("solr-ruby", "~> 0.0.8")
  gem.files = FileList['lib/fluent/plugin/out_solr.rb', 'lib/solr/request/commit.rb', '[A-Z]*'].to_a
  gem.bindir = '/etc/fluent/plugin'

end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
#  test.libs << 'lib' << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fluent-plugin-solr #{version}"
  rdoc.rdoc_files.include('README*')
end
