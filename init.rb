require 'bundler'
Bundler.require

require 'time'
require 'date'

#require la aplicacion
Dir['./app/app.rb'].sort.each { |req| require_relative req }

#require los controladores
Dir['./app/controllers/*.rb'].sort.each { |req| require_relative req }

#require los modelos
Dir['./app/models/*.rb'].sort.each { |req| require_relative req }