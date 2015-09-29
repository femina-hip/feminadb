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

task :deploy do
  task :symlink do
    after :shared, :configure-sunspot
  end
end
