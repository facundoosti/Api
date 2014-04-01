class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      
      t.datetime   :start 
      t.datetime   :end
      t.text       :status
      t.text       :user
      
      t.references :resource
 
      t.timestamps
    end
  end
end


