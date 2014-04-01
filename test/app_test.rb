#require File.expand_path(File.join('test', 'test_helper'))
require File.expand_path(File.join('..', 'test_helper'), __FILE__)
require 'resource'

describe App do
  include Rack::Test::Methods
  include Rack::Utils


  let(:app) { App }
  let(:host){ "http://example.org:80"} 
#GET /resources/////////////////////////////////////////////////////////////////////////////////////////////
  describe '/resources' do

    describe 'When resources are listed' do

      describe 'When there is not any resources loaded' do

        before do
          @pattern = {
                      resources: [
                      ],
                      links: [
                        {
                          rel: 'self',
                          uri: "#{host}/resources"
                        }
                      ]
                    }
          get '/resources'
        end

        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end

        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end
      end
      
      describe 'when a resource loaded' do
        before do
          r=Resource.create name: 'Resource', description: 'Description of Resource'
          @pattern = {
                      resources: [  name: String,
                                    description: String,
                                    links: [
                                      {
                                        rel: "self",
                                        uri: "#{host}/resources/#{r.id}"
                                      }
                                    ]
                                  ],
                                  links: [
                                    {
                                      rel: 'self',
                                      uri: "#{host}/resources"
                                    }
                                  ]
                                }
          get '/resources'
        end                  
        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end

        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end
      end
    end
  end

#GET /resources/:id_resource////////////////////////////////////////////////////////////////////////////////////////////
  describe '/resources/:id_resource' do
    
    describe 'When request a resource' do

      before do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        @pattern = {
                    resource: {
                    name: resource.name,
                    description: resource.description,
                    links: [
                      {
                        rel: 'self',
                        uri: "#{host}/resources/#{resource.id}",
                      },
                      {
                        rel: 'bookings',
                        uri: "#{host}/resources/#{resource.id}/bookings",
                      }
                    ]
                  }
                }
        get "/resources/#{resource.id}" 
      end
    
      it 'Should return a body with format' do
        last_response.body.must_match_json_expression(@pattern)
      end

      it 'Should return Status 200 OK' do
        last_response.must_be :ok?
      end

    end

    describe 'When request a resource not found' do
      before do
        get "/resources/1000"  
      end    

      it 'Should return Status 404 Not Found' do
        last_response.must_be :not_found?
      end  
    end
  end

#GET /resources/:id_resource/bookings////////////////////////////////////////////////////////////////////////////////////////////  
  describe '/resources/:id_resource/bookings?date=&limit=&status=' do  
    describe 'When request the reservations' do
      describe 'when the parameters are not' do
        before do
          @r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
          get "/resources/#{@r.id}/bookings"
          hash = JSON.parse last_response.body
          uri = URI(hash['links'].first["uri"])
          @params = Rack::Utils.parse_query(uri.query)
        end 
        it 'param date in uri should contain the following day' do
          (Date::today + 1.day).strftime('%F').must_equal @params["date"]
        end  
        it 'param limit in uri should contain 30' do
          30.to_s.must_equal @params["limit"]
        end
        it 'param status in uri should contain approved' do
          "approved".must_equal @params["status"]
        end
      end

      describe 'when the parameters are' do
        before do
          @r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
          @limit = 2
          @date = '2014-01-01'
          @status = 'all'
          get "/resources/#{@r.id}/bookings?date=#{@date}&limit=#{@limit}&status=#{@status}"
          hash = JSON.parse last_response.body
          uri = URI(hash['links'].first["uri"])
          @params = Rack::Utils.parse_query(uri.query)
        end 
        it 'param date in uri should contain those admitted' do
          @date.must_equal @params["date"]
        end  
        it 'param limit in uri should contain those admitted' do
          @limit.to_s.must_equal @params["limit"]
        end
        it 'param status in uri should contain those admitted' do
          @status.must_equal @params["status"]
        end
      end 

      describe 'When not exist reservations for date' do        
        before do
          r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
          Resource.create name: 'Aula Magna', description: 'Sala de dictado de conferencias magnas'

          b=Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: r 

          @pattern = {
                        bookings: [],
                        links: [
                          {
                            rel: "self",
                            uri: "#{host}/resources/#{r.id}/bookings?date=#{(Date.today + 1.day).to_s}&limit=30&status=approved"
                          }
                        ] 
                      }
          get "/resources/#{r.id}/bookings"           
        end

        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end
        
        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end
      end
      describe 'When exist reservations for date' do        
        before do
          r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 

          b=Booking.create start: Time.new(2014,01,01,11,0,0), :end => Time.new(2014,01,01,12,0,0) ,user:'user@user.com', resource: r 
          date='2014-01-01'
          limit=3
          status='all'
          @pattern = {
                     bookings: [
                      { 
                      start: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      end: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      status: b.status,
                      user: String,
                      links: [
                          {
                            rel: "self",
                            url: "#{host}/resources/#{r.id}/bookings/#{b.id}"
                          },
                          {
                            rel: "resource",
                            uri: "#{host}/resources/#{r.id}"
                          },  
                          {
                            rel: "accept",
                            uri: "#{host}/resources/#{r.id}/bookings/#{b.id}",
                            method: "PUT"
                          },
                          {
                            rel: "reject",
                            uri: "#{host}/resources/#{r.id}/bookings/#{b.id}",
                            method: "DELETE"
                          }
                        ]
                      }
                    ],
                    links: [
                      {
                        rel: "self",
                        uri: "#{host}/resources/#{r.id}/bookings?date=#{date}&limit=#{limit}&status=#{status}"
                      }
                    ]
                  }
          get "/resources/#{r.id}/bookings?date=#{date}&limit=#{limit}&status=#{status}"          
        end

        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end
        
        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end
      end      
      
      describe 'When request a resource not found' do
        before do
          get '/resources/1/bookings/1000'  
        end
        it 'Should return Status 404 Not Found' do
          last_response.must_be :not_found?
        end  
      end
    end
  end  
#Delete /resources/:id_resource/bookings/:id_booking////////////////////////////////////////////////////////////////////////////////////////////  
  describe '/resources/:id_resource/bookings/:id_booking' do 
    let (:resource) {Resource.create name: 'Resource', description: 'Description of Resource'}
    let (:booking)  {resource.bookings.create start: Time.now, end: Time.now}
    
    before do
      delete "/resources/#{resource.id}/bookings/#{booking.id}" 
    end 
    
    describe 'When a reservation is canceled' do
      it 'the body should be empty' do
        last_response.body.must_be_empty   
      end
      it 'the status should be 200 OK' do
        last_response.must_be :ok?  
      end
    end

    describe 'When a reservation is not canceled' do
      before do
        delete "/resources/#{resource.id}/bookings/#{booking.id}" 
      end
      it 'the body should be 404 Not Found' do
        last_response.must_be :not_found?
      end
    end 
  end

#GET /resources/:id_resource/bookings/:id_booking////////////////////////////////////////////////////////////////////////////////////////////  
  describe '/resources/:id_resource/bookings/:id_booking' do
    describe 'when a reservation request showing' do 
      before do
        r = Resource.create name: 'Resource', description: 'Description of Resource'
        booking = r.bookings.create start: Time.now, end: Time.now
        @pattern = {
                   from: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                   to: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                   status: booking.status,
                    links: [
                      {
                        rel: "self",
                        url:  "#{host}/resources/#{r.id}/bookings/#{booking.id}"
                      },
                      {
                        rel: "resource",
                        uri: "#{host}/resources/#{r.id}"
                      },
                      {
                        rel: "accept",
                        uri: "#{host}/resources/#{r.id}/bookings/#{booking.id}",
                        method: "PUT"
                     },
                     {
                       rel: "reject",
                       uri: "#{host}/resources/#{r.id}/bookings/#{booking.id}",
                       method: "DELETE"
                     }
                   ]
                 }
        get "/resources/#{r.id}/bookings/#{booking.id}"  
      end  
      it 'Should return a body with format' do
        last_response.body.must_match_json_expression(@pattern)
      end

      it 'Should return Status 200 OK' do
        last_response.must_be :ok?
      end
    end

    describe 'When request a resource not found' do
      before do
        get '/resources/1/bookings/1000'  
      end
      it 'Should return Status 404 Not Found' do
        last_response.must_be :not_found?
      end  
    end
  end  
#PUT /resources/:id_resource/bookings/:id_booking////////////////////////////////////////////////////////////////////////////////////////////  
  describe 'PUT /resources/:id_resource/bookings/:id_booking' do  
    describe 'When I authorize a reservation' do

      before do
        r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
        r2 =Resource.create name: 'Aula Magna', description: 'Sala de dictado de conferencias magnas'

        b=Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: r 
        Booking.create start: Time.new(2013,01,13,14,0,0), :end => Time.new(2013,01,13,17,0,0) ,user:'user@user.com', resource: r 
        Booking.create start: Time.new(2013,01,13,18,0,0), :end => Time.new(2013,01,13,20,0,0) ,user:'user@user.com', resource: r 
        Booking.create start: Time.new(2013,01,14,18,0,0), :end => Time.new(2013,01,15,20,0,0) ,user:'user@user.com', resource: r 
        @pattern = {
                    book:
                    {
                      from: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      to: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      status: 'approved',
                      links: [
                        {
                          rel: "self",
                          url: "#{host}/resources/#{r.id}/bookings/#{b.id}"
                        },
                        {
                          rel: "resource",
                          uri: "#{host}/resources/#{r.id}"
                        },
                        {
                          rel: "accept",
                          uri: "#{host}/resources/#{r.id}/bookings/#{b.id}",
                          method: "PUT"
                        },
                        {
                          rel: "reject",
                          uri: "#{host}/resources/#{r.id}/bookings/#{b.id}",
                          method: "DELETE"
                        }
                      ]
                    }
                  }  
        put "/resources/#{r.id}/bookings/#{b.id}"          
      end

      it 'Should return a body with format' do
        last_response.body.must_match_json_expression(@pattern)
      end
      
      it 'Should return Status 200 OK' do
        last_response.must_be :ok?
      end
    end

    describe 'when there is a reserve is approved for the requested period with same date' do
      before do
        @r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
       
        b = Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: @r 
        b.status = 'approved'
        b.save
        b1 = Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: @r 
        put "/resources/#{@r.id}/bookings/#{b1.id}"          
      end

      it 'the body should be 409 CONFLICT' do
        last_response.must_be :client_error?
      end    

      describe 'when there is a reserve is approved for the requested period with date >' do
        before do
          @r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
         
          b = Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: @r 
          b.status = 'approved'
          b.save
          b1 = Booking.create start: Time.new(2013,01,13,11,2,0), :end => Time.new(2013,01,13,11,45,0) ,user:'user@user.com', resource: @r 
          put "/resources/#{@r.id}/bookings/#{b1.id}"          
        end

        it 'the body should be 409 CONFLICT' do
          last_response.must_be :client_error?
        end
      end  
    end 

    describe 'When a reservation is not found' do
      before do
        put '/resources/1/bookings/100'
      end
      it 'the body should be 404 Not Found' do
        last_response.must_be :not_found?
      end
    end 
  end

#POST /resources/:id_resource/bookings////////////////////////////////////////////////////////////////////////////////////////////  
  describe 'POST /resources/:id_resource/bookings' do  
    describe 'When to create a reservation' do

      before do
        r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
    
        post "/resources/#{r.id}/bookings" , {from: '2014-01-01T10:00:00Z', to:'2014-01-01T12:00:00Z' }          
        
        @pattern = {
                    book:
                    {
                      from: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      to: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                      status: 'pending',
                      links: [
                        {
                          rel: "self",
                          url: /\Ahttp?\:\/\/.*\z/i
                        },
                        {
                          rel: "accept",
                          uri: /\Ahttp?\:\/\/.*\z/i,
                          method: "PUT"
                        },
                        {
                          rel: "reject",
                          uri: /\Ahttp?\:\/\/.*\z/i,
                          method: "DELETE"
                        }
                      ]
                    }
                  }  
      end

      it 'Should return a body with format' do
        last_response.body.must_match_json_expression(@pattern)
      end
      
      it 'Should return Status 201 Create' do
        last_response.must_be :successful?
      end
    
      describe 'when there is a reservation in the same period' do

        before do
          r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
          Booking.create start: Time.new(2014,01,01,10,0,0), :end => Time.new(2014,01,01,12,0,0) ,user:'user@user.com', resource: r 
         
          post "/resources/#{r.id}/bookings" , {from: '2014-01-01T10:00:00Z', to:'2014-01-01T12:00:00Z' }          
        end
        
        it 'Should return Status 409 Conflict' do
          last_response.must_be :client_error?
        end
      end

    end
  end
#GET /resources/1/availability?date=YYYY-MM-DD&limit=30////////////////////////////////////////////////////////////////////////////////////////////  
  describe 'GET /resources/:id_resource/availability' do  
    describe 'when the time blocks list available' do  
      describe 'when there is no block available to date' do  
        before do
          r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
      
          @pattern = {
                      availability: [
                      ],
                      links: [
                        {
                          rel: "self",
                          link: "#{host}/resources/#{r.id}/availability?date=#{(Date.today + 1.day).to_s}&limit=3"
                        }
                      ]
                    }
          get "/resources/#{r.id}/availability"
        end

        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end
        
        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end   
      end 
      describe 'when there is block available to date' do  
        before do
          r = Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 
          b=Booking.create start: Time.new(2014,01,01,10,0,0), :end => Time.new(2014,01,01,12,0,0) ,user:'user@user.com', resource: r ,status: :approved
          date = '2014-01-01'
          limit=3
          @pattern = {
                      availability: [
                        {
                          from: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                          to: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                          links: [
                            {
                              rel: "book",
                              link: "#{host}/resources/#{r.id}/bookings",
                              method: "POST"
                            },
                            {
                              rel: "resource",
                              uri: "#{host}/resources/#{r.id}"
                            }        
                          ]
                        },
                        {
                          from: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                          to: /\A\d\d\d\d-\d\d-\d\dT\d\d\:\d\d\:\d\dZ\z/,
                          links: [
                            {
                              rel: "book",
                              link: "#{host}/resources/#{r.id}/bookings",
                              method: "POST"
                            },
                            {
                              rel: "resource",
                              uri: "#{host}/resources/#{r.id}"
                            },        
                          ]
                        }
                      ],
                      links: [
                        {
                          rel: "self",
                          link: "#{host}/resources/#{r.id}/availability?date=#{date}&limit=#{limit}"
                        }
                      ]
                    }
          get "/resources/#{r.id}/availability?date=#{date}&limit=#{limit}"
        end

        it 'Should return a body with format' do
          last_response.body.must_match_json_expression(@pattern)
        end
        
        it 'Should return Status 200 OK' do
          last_response.must_be :ok?
        end   
      end

    end
  end    
end