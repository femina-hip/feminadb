# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rails::Application.load_tasks

require 'sunspot/rails/server'
require 'sunspot/rails/tasks'

begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end

begin
  require 'vlad'

  namespace :vlad do
    desc "Starts thin servers"
    remote_task :start_app, :roles => :app do
      run "/etc/init.d/thin start"
    end

    desc "Stops thin servers"
    remote_task :stop_app, :roles => :app do
      run "/etc/init.d/thin stop"
    end

    desc "Restarts thin servers"
    remote_task :restart_app, :roles => :app do
      Rake::Task['vlad:stop_app'].invoke
      Rake::Task['vlad:start_app'].invoke
    end

    desc "Starts delayed_job server"
    remote_task :start_bg, :roles => :app do
      run "RAILS_ENV=production #{deploy_to}/current/script/delayed_job start"
    end

    desc "Stops delayed_job server"
    remote_task :stop_bg, :roles => :app do
      run "RAILS_ENV=production #{deploy_to}/current/script/delayed_job stop"
    end

    desc "Restarts delayed_job servers"
    remote_task :restart_bg, :roles => :app do
      Rake::Task['vlad:stop_bg'].invoke
      Rake::Task['vlad:start_bg'].invoke
    end

    desc "Full deployment cycle: Update, migrate, restart, cleanup"
    remote_task :deploy, :roles => :app do
      Rake::Task['vlad:update'].invoke
      Rake::Task['vlad:migrate'].invoke
      Rake::Task['vlad:restart_app'].invoke
      Rake::Task['vlad:restart_bg'].invoke
      Rake::Task['vlad:cleanup'].invoke
    end
  end

  require 'vlad/git'
  class Vlad::Git
    def checkout(revision, destination)
      destination = File.join(destination, 'repo')
      revision = 'HEAD' if revision =~ /head/i

      ret = [ "([ -d #{destination} ] && (cd #{destination} && #{git_cmd} checkout master && #{git_cmd} pull origin master) || #{git_cmd} clone #{repository} #{destination})",
        "(cd #{destination} && ([ -f .git/refs/heads/deployed-#{revision} ] && #{git_cmd} branch -D deployed-#{revision} || true) && #{git_cmd} checkout -f -b deployed-#{revision} #{revision})",
      ].join(" && ")
    end
  end

  Vlad.load(:app => nil, :scm => :git)
rescue LoadError
  # do nothing
end
