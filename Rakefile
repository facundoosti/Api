require 'rake/testtask'
require 'micro_migrations'
require 'sinatra/base'
require 'sinatra/contrib'


Rake::TestTask.new('test') do |t|
  t.libs << "./app/models"
  t.libs << "./app/controllers"
  t.pattern = 'test/**/*_test.rb'
end

desc 'Start a console'
task :console do
  ENV['RACK_ENV'] ||= 'development'
  %w(irb irb/completion).each { |r| require r }
  require_relative 'init'

  ARGV.clear
  IRB.start 
end
