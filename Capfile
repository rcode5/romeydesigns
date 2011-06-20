require 'bundler/capistrano'
require 'rvm'
require 'rvm/capistrano'

# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require "rvm/capistrano"

set :rvm_ruby_string, '1.9.2@wallerblock'

####### VARIABLES #######
set :application, "wallerblock"
set :user, 'wallerblock'
set :use_sudo, false

set :scm, :git
set :repository,  "ssh://git.bunnymatic.com/projects/git/wallerblock.git"
set :deploy_via, :remote_cache
set :deploy_to "/home/#{user}/webapp"

server 'bunnymatic.com', :app, :web, :db, :primary => true
set :runner, user
set :admin_runner, user

namespace :deploy do
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R config.ru start"
  end
 
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup thin -C thin/production_config.yml -R config.ru stop"
  end
 
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end
 
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :cold do
    deploy.update
    deploy.start
  end
end

####### Apache commands ####
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo -u www /etc/init.d/httpd #{action.to_s}", :via => run_method
    end
  end
end

after "deploy:start", "apache:reload"
