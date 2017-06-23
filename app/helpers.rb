module Helpers

  def host
    request.scheme + "://" +request.host + ":" + request.port.to_s
  end

  def valid_strict_date a_date, other_date
    a_date <= other_date
  end 
    
  def links operando, str, *method
    hash = {rel: operando, uri: "#{host}#{str}"}
    hash[:method] = method.first unless (method.empty?)
    hash     
  end
  
  def links_to_book id,resource_id
    vec = [{rel:'self', uri:"#{host}/resources/#{resource_id}/bookings/#{id}"}]
    vec << {rel:'resource', uri:"#{host}/resources/#{resource_id}"}
    vec << links('accept',"/resources/#{resource_id}/bookings/#{id}", 'PUT')
    vec << links('reject',"/resources/#{resource_id}/bookings/#{id}",'DELETE')
    vec
  end

  def links_for_bookings bookings
     bookings.each do |book|
        id = book["links"]["id"]
        resource_id = book["links"]["resource_id"]
        book["links"] = links_to_book(id,resource_id)         
      end
      bookings 
  end

end