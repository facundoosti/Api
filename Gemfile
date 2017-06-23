source 'https://rubygems.org'

gem 'sinatra', require: 'sinatra/base' 
gem 'sinatra-contrib', require: 'sinatra/reloader'
gem 'micro_migrations', github: 'svenfuchs/micro_migrations'
gem 'mysql2'
gem 'activerecord', require: 'active_record'
gem 'enumerize', require: 'enumerize'

group :test do
  gem 'rack-test', require: 'rack/test'
  gem 'rack', require: 'rack'
  gem 'database_cleaner', require: 'database_cleaner'
  gem 'minitest', require: ['minitest/autorun', 'minitest/spec']
  gem 'json_expressions', require: 'json_expressions/minitest'
end

group :development do
	gem 'pry'
  gem 'tux'
  gem 'rb-readline', '~> 0.5.1'
end
group :development, :test do
  gem 'sqlite3', require: 'sqlite3'
  gem 'rake'
end
