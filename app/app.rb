class App < Sinatra::Base
  set :root, Dir.pwd

  #Autorizate
  set(:auth) do |*roles|   # <- notice the splat here
    unless logged_in? && roles.any? {|role| current_user.in_role? role }
      halt 404#redirect "/login/", 303
    end
  end

  # ActiveRecord
  environment = ENV['RACK_ENV'] || 'development'
  hash = YAML.load(File.new(root + '/config/database.yml'))[environment]
  ActiveRecord::Base.establish_connection(hash)
  ActiveRecord::Base.connection
  ActiveRecord::Base.include_root_in_json = false

  before { content_type :json}  

  after { ActiveRecord::Base.connection.close }
  
  # Helpers
  helpers do
    require_relative './helpers'
    include Helpers    
  end  

  configure :development do
    register Sinatra::Reloader
    also_reload 'app/models/*.rb'
    also_reload 'app/controllers/*.rb'
  end
end
