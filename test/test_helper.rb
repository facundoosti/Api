require 'bundler'
ENV['RACK_ENV'] = 'test'

Bundler.require :default, ENV['RACK_ENV'].to_sym
require File.expand_path(File.join('init'))
require_relative '../app/helpers.rb'

require 'time'

class Minitest::Spec
  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
