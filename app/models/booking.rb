class Booking < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  enumerize :status, in: [:approved, :pending], default: :pending

  # associations
  belongs_to :resource
                      
  #methods
  def whith_status status
    (self.status == status) || (status == 'all')
  end

  def self.status_validator status
    [:approved, :pending, :all].include? status.to_sym
  end

  def links
    {id:self.id,resource_id:self.resource.id}
  end
 
=begin 
  # valdations to Email
  class UserValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        record.errors[attribute] << (options[:message] || "is not an email")
      end
    end
 end
  
=end
  # validations
  validates :start, presence: true 
  validates :resource, presence: true
 # validates :user, user: true 

end