set :application, 'feminadb'
set :repo_url, 'https://github.com/femina-hip/feminadb.git'
set :deploy_to, '/opt/rails/feminadb'
set :passenger_in_gemfile, true
set :linked_dirs, fetch(:linked_dirs, []).push('solr', 'log')

desc 'Configure sunspot-solr'
task :'configure-sunspot' do
  on roles(:db) do |host|
    within release_path do
      execute :bundle, 'exec', 'sunspot-installer'
    end
  end
end

desc 'Reindex all customers, so searches work properly'
task :reindex do
  on roles(:db) do |host|
    within release_path do
      with(RAILS_ENV: 'production') { execute :bundle, 'exec', 'rake', 'sunspot:reindex' }
    end
  end
end

namespace :deploy do
  task :restart do
    on roles(:app) do |host|
      # The working directory of Passenger and Solr may be deleted. Kill them,
      # so systemd will restart them in the newest directory.
      execute(:kill, '-9', '$(systemctl show feminadb-index | grep ExecMainPID | cut -d= -f2)')
      execute(:kill, '-9', '$(systemctl show feminadb | grep ExecMainPID | cut -d= -f2)')
    end
  end
  after(:publishing, :'deploy:restart')

  task :symlink do
    after :shared, :'configure-sunspot'
  end
end
