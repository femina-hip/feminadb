Rake::Task['assets:environment'].clear
namespace :assets do
  task :environment do
    # https://github.com/rails/sprockets-rails/blob/master/lib/sprockets/rails/task.rb
    ENV['SECRET_KEY_BASE'] = 'assets-dummy'
    Rake::Task['environment'].invoke
  end
end
