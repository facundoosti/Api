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
 
  # validations
  validates :start, presence: true 
  validates :resource, presence: true
end