class Resource < ActiveRecord::Base
  # asssociations
  has_many :bookings, inverse_of: :resource

  #methods
  def links
    self.id
  end

  def bookings_pending
    bookings.where(status: 'pending')
  end
  
  def bookings_approved
    bookings.where(status: 'approved')
  end
  
  def bookings_approved_since from, to
    bookings_approved.where('start >= ? AND start <= ? OR end >= ? AND end <= ?', from, to, from, to)
  end

  def available_to_book? from, to
    result = bookings_approved_since from, to
    result.empty? 
  end

  def occuped_block? from, to
    result = bookings.where('start >= ? AND start <= ? OR end >= ? AND end <= ?', from, to, from, to)
    result.empty? 
  end

  def cancel_pending_bookings
    bookings_pending.destroy_all
  end
  
  def bookings_since_to date, limit
    bookings.order(:start).where('start >= ? AND end <= ?',date,limit)  
  end
  
  #validations
  validates :name,:description,  presence: true, uniqueness: true
  validates_associated :bookings

end