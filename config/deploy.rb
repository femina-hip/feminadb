ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :runner, "root"

set :application, "feminadb"
set :repository, "svn+ssh://feminabuntu/var/lib/svn/feminadb/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"
set :deploy_to, "/var/lib/rails/feminadb"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "feminabuntu"
role :web, "feminabuntu"
role :db,  "feminabuntu", :primary => true

set :keep_releases, 2
set :deploy_via, 'export'

namespace :deploy do
  task :stop, :roles => :app do
    as = fetch(:runner, "app")
    via = fetch(:run_method, :sudo)

    invoke_command "/etc/init.d/rails stop", :via => via, :as => as
  end

  task :start, :roles => :app do
    as = fetch(:runner, "app")
    via = fetch(:run_method, :sudo)

    invoke_command "/etc/init.d/rails start", :via => via, :as => as
  end

  task :restart, :roles => :app do
    as = fetch(:runner, "app")
    via = fetch(:run_method, :sudo)

    invoke_command "/etc/init.d/rails restart", :via => via, :as => as
  end
end

desc "Preserve ferret index"
task :after_update_code, :roles => :web do
  run <<-EOF
    #{latest_release}/script/runner 'Sass::Plugin::update_stylesheets'
  EOF
  run <<-EOF
    ln -s #{shared_path}/index/production #{latest_release}/index/production
  EOF
end
