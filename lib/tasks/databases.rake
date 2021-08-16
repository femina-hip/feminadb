# https://github.com/rails/rails/blob/843c0a3fcde18011d9360762b07e0ab11910ec73/activerecord/lib/active_record/railties/databases.rake
# ... Rails won't run unless SECRET_KEY_BASE is set. But it's useless.
namespace :db do
  # Monkey-patch: anything that needs :enviroment used to read from the root
  # namespace, and now it'll read from the db namespace.
  task :environment do
    ENV['SECRET_KEY_BASE'] = 'assets-dummy'
    Rake::Task['environment'].invoke
  end
end
