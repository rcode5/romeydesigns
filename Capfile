# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require 'bundler/capistrano'
require 'rvm'
require 'rvm/capistrano'

set :rvm_ruby_string, '1.9.2-p180@romey'
set :rvm_type, :root
load 'deploy' if respond_to?(:namespace)

####### VARIABLES #######
set :application, "romey"
set :user, "romey"
set :use_sudo, false

set :scm, :git
set :repository,  "ssh://git.bunnymatic.com/projects/git/romeydesigns.git"
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/webapp"

set :deploy_server, 'bunnymatic.com'
role :app, deploy_server
role :web, deploy_server
role :db, deploy_server, :primary => true

set :runner, user
set :admin_runner, user

set :shared_db_dir, 'shared/database'
set :db_file, 'romey.db'
set :shared_backup__dir, 'shared/backups'

namespace :romey do
  namespace :db do

    task :copy_db do
      run "cd #{deploy_to} && cp #{shared_db_dir}/#{db_file} #{shared_backup_dir}/latest/"
    end

    task :stash_latest do
      run "cd #{deploy_to} && if [ -d #{shared_backup_dir}/latest ]; then mv #{shared_backup_dir}/latest #{shared_backup_dir}/#{Time.now.strftime('%Y%m%d%H%M%s')}; fi"
    end

    task :symlink do
      run "cd #{deploy_to} && rm -f current/#{db_file} && ln -s #{shared_db_dir}/#{db_file} current/"
    end

    desc "Backup database"
    task :backup, :roles => [:web, :app] do
      romey.db.setup_backup_dir
      romey.db.copy_db
      romey.db.stash_latest
    end
    
  end
end

namespace :deploy do

  desc "Deploy and start #{application} : #{deploy_server}:#{deploy_to}"
  task :start, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R config.ru start"
  end
 
  desc "Stop #{application} : #{deploy_server}:#{deploy_to}"
  task :stop, :roles => [:web, :app] do
    run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/production_config.yml -R config.ru stop"
  end
 
  desc "Stop then start #{application} : #{deploy_server}:#{deploy_to}"
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

before "deploy:start", "romey:db:backup"
after "deploy:update_code", "romey:db:symlink"
after "deploy:start", "deploy:symlink", "apache:reload"

