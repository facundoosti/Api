class App < Sinatra::Base
  # Listar todos los recursos
  get '/resources' do
    resources = JSON.parse Resource.all.to_json(only: [:name, :description], methods: :links)
    resources.each { |r| r['links'] = [links('self', "/resources/#{r['links']}")] }
    { resources: resources, links: [links('self', request.path)] }.to_json
  end

  # Ver un recurso
  get '/resources/:id_resource' do
    begin
      resource = JSON.parse(Resource.find(params[:id_resource]).to_json(root: true, only: [:name, :description], methods: :links))
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    resource['resource']['links'] = [links('self', request.path)]
    resource['resource']['links'] << links('bookings', "#{request.path}/bookings")
    resource.to_json
  end

  # Modificar recurso
  put '/resources/:id_resource' do
    begin
      resource = Resource.find(params[:id_resource])
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    {resource: resource}.to_json if resource.update name: params[:name] , description: params[:description]
  end  

  # Crea un nuevo recurso
  post '/resources' do 
    halt 409 unless (Resource.find_by name: params[:name]).nil? 
    resource = Resource.create name: params[:name] , description: params[:description]
    {resource: resource}.to_json
  end  


  # Listar reservas de un recurso
  get '/resources/:id_resource/bookings' do
  
    date = Validator.validate_param_date params[:date] 
    limit = Validator.validate_param_limit params[:limit], 30 
    status = Validator.validate_param_status params[:status] 
    
    params_path = "?date=#{date}&limit=#{limit}&status=#{status}"
    
    limit = date + (limit.day)

    begin
      bookings = JSON.parse(Resource.find(params[:id_resource]).bookings_since_to(date.iso8601, limit.iso8601).select { |b| b.whith_status status }.to_json(only: [:start, :end, :status, :user], methods: :links))
      
      bookings = links_for_bookings(bookings)
      JSON.generate({ bookings: bookings , links: [links('self', request.path+params_path)] })
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    rescue ArgumentError
      redirect '/resources', 303
    end 
  end

  # Disponibilidad de un recurso a partir de una fecha

  get '/resources/:id_resource/availability' do
    date = Validator.validate_param_date params[:date] 
    limit = Validator.validate_param_limit params[:limit], 3 

    params_path= "?date=#{date}&limit=#{limit}"
    limit = date + (limit.day)
    
    begin
      bookings = Resource.find(params[:id_resource]).bookings_approved_since(date.iso8601, limit.iso8601)
    rescue ActiveRecord::RecordNotFound => e
        halt 404
    end

    date = (Time.parse date.to_s).utc.iso8601
    limit =(Time.parse limit.to_s).utc.iso8601
    
    hash = { availability: [], links: [] }

    unless bookings.first.nil?
      if bookings.first.start < date
        date = bookings.first.end
        bookings.delete_at(bookings.index(bookings.first))
      end

      from = date

      bookings.each do |book|
        to = book.start
        link = [{rel:'book', link: "#{host}/resources/#{book.resource.id}/bookings", method:'POST'}]
        link << links('resource', "/resources/#{book.resource.id}")
        hash[:availability] << { from: from, to: to, links: link }
        from = book.end
      end

      if bookings.last.end > limit
        to = bookings.last.start
      end

      to = limit
      link = [{rel:'book', link: "#{host}/resources/#{params[:id_resource]}/bookings", method:'POST'}]
      link << links('resource', "/resources/#{params[:id_resource]}")
      hash[:availability] << { from: from, to: to, links: link }

    end  

    hash[:links] << { rel: 'self', link: "#{host}#{request.path}#{params_path}" }
    JSON.generate(hash)
  end

  # reservar recurso
  # curl -v -d 'from='2013-12-03T20:39:01Z'&to='2013-11-14T14:00:00Z'' http://localhost:9292/resources/1/bookings
  post '/resources/:id_resource/bookings' do
    begin
      resource = Resource.find(params[:id_resource])
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    
    from = DateTime.parse params[:from]
    to   = DateTime.parse params[:to]
    
    halt 409 unless valid_strict_date(from, to)
    halt 409 unless resource.occuped_block?(from, to)

    booking=resource.bookings.create start: from.iso8601, end: to.iso8601
    book = JSON.parse(booking.to_json(only: [:start, :end, :status], methods: :links))
    book['links'] = links_to_book(book['links']['id'].to_s, book['links']['resource_id'].to_s)
    book['links'].delete_if {|hash| hash[:rel] == 'resource'}
    book.replace(from: book['start'], to: book['end'], status: book['status'], links: book['links'])
    response.status = 201
    JSON.generate({ book: book })
  end

  # cancelar reserva
  # curl -v -X DELETE localhost:9292/resources/1/bookings/3
  delete '/resources/:id_resource/bookings/:id_booking' do
    begin
      book = Resource.find(params[:id_resource]).bookings.find(params[:id_booking])
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    book.destroy
  end

  # autorizar reserva
  # curl -v -d '' -X PUT localhost:9292/resources/1/bookings/2
  put '/resources/:id_resource/bookings/:id_booking' do
    begin
      resource = Resource.find(params[:id_resource])
      booking = resource.bookings.find(params[:id_booking])
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    halt 409 unless resource.available_to_book?(booking.start, booking.end)  
    booking.update status: :approved
    resource.cancel_pending_bookings
    book = JSON.parse(booking.to_json(only: [:start, :end, :status], methods: :links))
    book['links'] = links_to_book(book['links']['id'].to_s, book['links']['resource_id'].to_s)
    book.replace(from: book['start'], to: book['end'], status: book['status'], links: book['links'])
    JSON.generate({ book: book })
  end

  # mostrar reserva
  get '/resources/:id_resource/bookings/:id_booking' do
    begin
      book = JSON.parse(Resource.find(params[:id_resource]).bookings.find(params[:id_booking]).to_json(only: [:start, :end, :status], methods: :links))
    rescue ActiveRecord::RecordNotFound => e
      halt 404
    end
    book['links'] = links_to_book(book['links']['id'].to_s, book['links']['resource_id'].to_s)
    JSON.generate(book.replace(from: book['start'], to: book['end'], status: book['status'], links: book['links']))
  end
end
