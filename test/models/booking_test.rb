require File.expand_path(File.join('test', 'test_helper'))
require 'booking'
require 'resource'

describe 'booking' do

  let (:booking) { Booking.create }
  let (:other_booking) do
      r =Resource.create name: 'Resource', description: 'Description of Resource'
      r.bookings.create start: Time.new(2013, 01, 13, 11, 0, 0), end: Time.new(2013, 01, 13, 12, 0, 0) 
  end

  describe '#create' do
    describe 'When required attributes are not present' do
      it 'valid? is false' do
        booking.valid?.must_equal false
      end
    end

    describe 'When required attributes are present' do
      it 'valid? is true' do
        other_booking.valid?.must_equal true
      end
    end

    describe 'When a book is created without resource' do
      it 'valid? is false' do
        booking = Booking.create start: Time.new(2013, 01, 13, 11, 0, 0), end: Time.new(2013, 01, 13, 12, 0, 0)
        booking.valid?.must_equal false
      end
    end
  
    describe 'When a book is created with resource' do
      it 'valid? is true' do
        other_booking.valid?.must_equal true
      end
    end
  
  end

  describe '#status_validator' do
    describe 'when argument is all' do
      it 'should return true' do
        Booking.status_validator('all').must_equal true
      end
    end
    describe 'when argument is approved' do
      it 'should return true' do
        Booking.status_validator('approved').must_equal true
      end
    end
    describe 'when argument is pending' do
      it 'should return true' do
        Booking.status_validator('pending').must_equal true
      end
    end
    describe 'when argument not exist in array' do
      it 'should return false' do
        Booking.status_validator('zaraza').wont_equal true
      end
    end
  end
  describe '#whith_status' do

    describe "When param is equals to the object's state" do
      it 'Should be true' do
        other_booking.whith_status('pending').must_equal true
      end
      it 'Should be true' do
        other_booking.status = 'approved'
        other_booking.whith_status('approved').must_equal true
      end  
    end  
    
    describe "When param is diferent to the object's state" do
      it 'Should be false' do
        other_booking.whith_status('approved').wont_equal true
      end
      it 'Should be false' do
        other_booking.status = 'approved'
        other_booking.whith_status('pending').wont_equal true
      end  
    end

    describe "When param is equals to 'all'" do
      it 'Should be true' do
        other_booking.whith_status('all').must_equal true
      end
    end
    
    describe "When param is diferent to 'all'" do
      it 'Should be true' do
        other_booking.whith_status('pepe mujica').must_equal false
      end
    end

  end
    
  describe '#links' do
    
    it 'Should return a hash' do
      other_booking.links.must_be_instance_of  Hash
    end
  
    describe "When request the booking's id" do
      it 'Should be' do
        other_booking.id.must_equal other_booking.links[:id]
      end
    end

     describe "When request the booking's resource_id" do
      it 'should be' do
        other_booking.resource.id.must_equal other_booking.links[:resource_id]
      end
    end
  
  end    

end
#////////////////////////////////////////////////////////////////////////////////////////////






