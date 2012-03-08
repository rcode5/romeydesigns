require 'datamapper'
require './romey.rb'

desc 'run the server'
task :run do |t|
  require File.join(File.dirname(__FILE__),'romey')
  Romey.run!
end

begin
  require 'rspec/core/rake_task'
  desc "run specs"
  RSpec::Core::RakeTask.new
rescue Exception => ex
  puts "Failed to include RSpec rake tasks - should be ok for production environments"
end


namespace :db do
  desc "Migrate database with DataMapper auto_upgrade"
  task :migrate do
    EventResource.auto_upgrade!
    ImageResource.auto_upgrade!
    BabyImageResource.auto_upgrade!
    KeywordResource.auto_upgrade!
  end
end

begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end
