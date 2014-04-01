class Validator
  
  def self.valid_date? date  #fecha con formato 'YYYY-MM-DD'
    raise unless date.is_a? String
    valid_date = false
    valid_date = true if date =~ /\A\d\d\d\d-\d\d-\d\d\z/ unless (date.empty?)
    valid_date
  end  
  
  def self.validate_param_date param_date
    param_date ||= ''
    (param_date.empty? | !(valid_date? param_date)) ? date = Date.parse((Time.now + 1.day).strftime('%F')) : date = Date.parse(param_date)
  end

  def self.validate_param_limit param_limit, default
    param_limit  ||= '' 
    param_limit = default.to_s if (param_limit.to_i == 0) | (param_limit.to_i > 365)
    (param_limit.empty?) ? limit = default : limit = param_limit.to_i
  end

  def self.validate_param_status param_status
    
    param_status ||= '' 

    status_validate = Booking.status_validator param_status

    if param_status.empty? | !status_validate
      status = 'approved'
    elsif status_validate
      status = param_status
    end
  end

end 