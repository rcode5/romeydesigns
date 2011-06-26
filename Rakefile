require 'datamapper'
require './romey.rb'

desc 'run the server'
task :run do |t|
  require './romey.rb'
  Romey.run!
end

task :migrate do
  DataMapper.auto_migrate!
end

