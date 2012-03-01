require 'datamapper'
require './romey.rb'

desc 'run the server'
task :run do |t|
  require File.join(File.dirname(__FILE__),'romey')
  Romey.run!
end

namespace :db do
  desc "Migrate database with DataMapper auto_upgrade"
  task :migrate do
    EventResource.auto_upgrade!
    ImageResource.auto_upgrade!
    BabyImageResource.auto_upgrade!
  end
end

