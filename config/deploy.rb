require 'bundler/capistrano'
require 'rvm'
require 'rvm/capistrano'

####### VARIABLES #######
set :application, "WallerBlock"
set :scm, :git
set :use_sudo, false

deploy_version = "master"

set :repository,  "ssh://git.bunnymatic.com/projects/git/wallerblock.git"

server 'bunnymatic.com', :app, :web, :db, :primary => true

####### Apache commands ####
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo -u www /etc/init.d/httpd #{action.to_s}", :via => run_method
    end
  end
end

namespace :thin do
  desc "Start the Thin processes"
  task :start do
    sudo "bundle exec thin start -C thin.yml"
  end

  desc "Stop the Thin processes"
  task :stop do
    sudo "bundle exec thin stop -C thin.yml"
  end

  desc "Restart the Thin processes"
  task :restart do
    sudo "bundle exec thin restart -C thin.yml"
  end
end

namespace :nginx do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Nginx"
    task action, :roles => :web do
      invoke_command "sudo -u www-data /etc/init.d/nginx #{action.to_s}", :via => run_method
    end
  end
end


####### CUSTOM TASKS #######
desc "Deploy #{application} (#{deploy_version})"
task :prod do
  set :user, "wallerblock"
  set :deploy_to, "/home/wallerblock/webapp"
  set :ssh_port, '2222'
end

after 'bundle:install', 'deploy:migrate'
after "deploy:symlink", "apache:reload"


desc "Symlink data (NOOP)"
task :symlink_data do
end
