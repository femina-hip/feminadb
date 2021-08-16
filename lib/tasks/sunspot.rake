# ... Rails won't run unless SECRET_KEY_BASE is set. But it's useless.
namespace :sunspot do
  # Monkey-patch: anything that needs :enviroment used to read from the root
  # namespace, and now it'll read from the db namespace.
  task :environment do
    ENV['SECRET_KEY_BASE'] = 'sunspot-dummy'
    Rake::Task['environment'].invoke
  end
end
