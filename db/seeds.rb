require './init'

r=Resource.create name: 'sala de conferencias', description: "Sala en donde se realizan las conferencias en la organizacion" 

5.times do |num|
  Resource.create(name: "Aula #{num}", description: "Aula de Clases #{num}")
end
r2 =Resource.create name: 'Aula Magna', description: 'Sala de dictado de conferencias magnas'

Booking.create start: Time.new(2013,01,13,11,0,0), :end => Time.new(2013,01,13,12,0,0) ,user:'user@user.com', resource: r 
Booking.create start: Time.new(2013,01,13,14,0,0), :end => Time.new(2013,01,13,17,0,0) ,user:'user@user.com', resource: r 
Booking.create start: Time.new(2013,01,13,18,0,0), :end => Time.new(2013,01,13,20,0,0) ,user:'user@user.com', resource: r 
Booking.create start: Time.new(2013,01,14,18,0,0), :end => Time.new(2013,01,15,20,0,0) ,user:'user@user.com', resource: r 



b1 = Booking.create start: Time.new(2014,01,13,11,0,0), end:Time.new(2014,01,13,12,0,0),user:'user@user.com', resource: r
b1.status = 'approved'
b1.save

b1 = Booking.create start: Time.new(2014,01,13,18,0,0), end:Time.new(2014,01,13,20,0,0),user:'user@user.com', resource: r
b1.status = 'approved'
b1.save


b1 = Booking.create start: Time.new(2014,01,14,11,0,0), end:Time.new(2014,01,14,12,0,0),user:'user@user.com', resource: r
b1.status = 'approved'
b1.save






