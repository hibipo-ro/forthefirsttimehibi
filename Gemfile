source "https://rubygems.org"
git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }
gem 'sinatra', :github => 'sinatra/sinatra'
gem 'sinatra-contrib'
gem 'rake'
gem "minitest"
gem "rack-test"
gem 'mysql2-cs-bind'
gem 'pg'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'rack_csrf', '~> 2.5'
gem 'pg'
gem 'mysql2', groups: %w(test development), require: false
# gem 'rails_12factor', group: :production
gem 'pry-byebug'
# group :development do
#   gem 'mysql2'
# end
group :production, :development do
  gem 'mysql'
  gem 'mysql2'
end
group :test do
  gem 'rspec'
  gem 'rack-test'
end
# gem 'sqlite3', groups: %w(test development), require: false


