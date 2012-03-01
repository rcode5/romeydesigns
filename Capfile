# Add RVM's lib directory to the load path.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
# Load RVM's capistrano plugin.
require 'bundler/capistrano'
require 'rvm'
require 'rvm/capistrano'

set :rvm_ruby_string, '1.9.2-p290@romey'
set :rvm_type, :root
load 'deploy' if respond_to?(:namespace)

####### VARIABLES #######
set :application, "romey"
set :use_sudo, false

set :scm, :git
set :repository,  "ssh://git.bunnymatic.com/projects/git/romeydesigns.git"
set :deploy_via, :remote_cache
set :rails_env, 'development'

desc 'Setup Development Deployment Params'
task :dev do
  set :user, "deploy"
  set :deploy_to, "/home/deploy/romeydev"
  set :ssh_port, '22022'
  set :server_name, 'dev.romeydesigns.com'
  set :rails_env, 'development'
end
task :prod do
  set :user, "romey"
  set :deploy_to, "/home/#{user}/webapp"
  set :ssh_port, '22022'
  set :server_name, 'www.romeydesigns.com'
  set :rails_env, 'production'
end

set :deploy_server, 'bunnymatic.com'
role :app, deploy_server
role :web, deploy_server
role :db, deploy_server, :primary => true

task :set_runners do
  set :runner, user
  set :admin_runner, user
end

set :shared_db_dir, 'shared/database'
set :db_file, 'romey.db'
set :shared_backup_dir, 'shared/backups'
set :deploy_time, Time.now.strftime('%Y%m%d%H%M%s')

namespace :romey do
  namespace :db do

    task :copy_to_current do
      run "cd #{deploy_to} && if [ -f #{previous_release}/#{db_file} ]; then cp #{previous_release}/#{db_file} #{current_release}; fi"
    end
   
  end
end

namespace :deploy do
  # This will make sure that Capistrano doesn't try to run rake:migrate (this is not a Rails project!)
  task :start, :roles => [:web, :app] do
    thin.start
  end

  task :stop, :roles => [:web, :app] do
    thin.stop
  end

  task :restart do
    deploy.stop
    deploy.start
  end

  task :cold do
    deploy.update
    thin.stop
    deploy.start
  end

end

####### Apache commands ####
namespace :thin do
  [:stop, :start].each do |action|
    desc "#{action.to_s} thin servers for #{application} : #{deploy_server}:#{deploy_to} [env #{rails_env}]"
    task action, :roles => [:web, :app] do
      run "cd #{deploy_to}/current && nohup bundle exec thin -C thin/#{rails_env}_config.yml -R config.ru #{action.to_s}"
    end
  end

  desc "Restart thin servers for #{application} : #{deploy_server}:#{deploy_to}"
  task :restart, :roles => [:web, :app] do
    deploy.stop
    deploy.start
  end

end

namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo -u www /etc/init.d/httpd #{action.to_s}", :via => run_method
    end
  end
end

desc "Sanity Check"
task :checkit do
  puts("User: %s" % user)
  puts("Repo: %s" % repository)
  puts("DeployDir: %s" % deploy_to)
  puts("SSH Port: %s" % ssh_port)
end

desc "ping the server"
task :ping do
  run "curl -s http://#{server_name}/feeds/feed"
  run "curl -s http://#{server_name}"
end
before 'deploy', :set_runners
before "thin:start", "romey:db:copy_to_current"
after 'deploy:cold', "apache:reload"
after "apache:reload", :ping

