require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'sqlite3://localhost/herdb.db')