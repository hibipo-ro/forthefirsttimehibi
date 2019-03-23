# frozen_string_literal: true

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


group :development do
  gem 'mysql2'
end

group :production do
  gem 'pg'
  gem "activerecord-postgresql-adapter"
end


