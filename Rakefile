require 'rake'
require 'rubygems'
require 'active_record'
require 'yaml'

task :default => 'db:migrate'

namespace :db do

  desc "Migrate the database. Target specific version with VERSION=x"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate",  ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  task :environment do
    APP_ENV = (ENV['APP_ENV'] ||= 'development')
    dbconfig = YAML.load(File.open('config/database.yml'))[APP_ENV]
    ActiveRecord::Base.establish_connection(dbconfig)
    ActiveRecord::Base.colorize_logging = false
    logFile = File.open('log/database.log','w')
    ActiveRecord::Base.logger = Logger.new(logFile)
  end
end


