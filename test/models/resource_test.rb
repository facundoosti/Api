require File.expand_path(File.join('test', 'test_helper'))
require 'resource'

describe 'resource' do
  let (:resource) { Resource.create }


  describe '#create' do
    describe 'when required attributes are not present' do
      it 'valid? is false' do
        resource.valid?.must_equal false
      end
    end

    describe 'when required attributes are present' do
      it 'valid? is true' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource.must_be :valid?
      end
    end

    describe 'when attributes are present in the DB' do
      it 'valid? is false' do
        Resource.create name: 'Resource', description: 'Description of Resource'
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource.valid?.must_equal false
      end
    end

  end


  describe '#links' do
    describe "Should return the resource's id" do
      it 'resource.links' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource.id.must_equal resource.links
      end
    end
  end

  describe '#bookings_approved_since' do
    describe 'When instance create' do
      it 'Should return a ActiveRecord::AssociationRelation::ActiveRecord_AssociationRelation_Booking' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource.bookings_approved_since('from', 'to').must_be_instance_of(ActiveRecord::AssociationRelation::ActiveRecord_AssociationRelation_Booking)
      end
    end

    describe 'When not bookings exist' do
      it 'Must be empty' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource.bookings_approved_since('from', 'to').must_be_empty resource.bookings_approved_since 'from', 'to'
      end
    end

    describe 'When inspect the status reserve' do
      it 'Should be approved' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        from = Time.utc(2013, 1, 1)
        to = Time.utc(2013, 1, 3)
        book = Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
        book.update status: :approved
        resource.bookings_approved_since(from, to).to_enum.all? { |b| b.status == 'approved' }.must_equal true
      end
    end

    describe 'When you add a reservation approved within of the range' do
      it 'Should increment the size of the collection one more' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        from = Time.utc(2013, 1, 1)
        to = Time.utc(2013, 1, 3)
        book = Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
        book.update status: :approved
        resource.bookings_approved_since(from, to).size.must_equal 1
        resource
      end
    end
  end

  describe '#available_to_book?' do
    describe 'When not exist reserve approved within the range' do
      it 'Should return true' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        from = Time.utc(2013, 1, 1)
        to = Time.utc(2013, 1, 3)
        resource.available_to_book?(from, to).must_equal true
      end
    end

    describe 'When exist reserve approved within the range' do
      it 'Should return false' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        from = Time.utc(2013, 1, 1)
        to = Time.utc(2013, 1, 3)
        book = Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
        book.update status: :approved
        resource.available_to_book?(from, to).wont_equal true
      end
    end
  end
  describe '#bookings_pending' do
    it 'Should return the bookings with status pending' do
      resource = Resource.create name: 'Resource', description: 'Description of Resource'
      from = Time.utc(2013, 1, 1)
      to = Time.utc(2013, 1, 3)
      book = Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
      book.update status: :approved
      Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
      resource.bookings_pending.first.status.must_equal 'pending'
    end
  end
  describe '#bookings_approved' do
    it 'Should return the bookings with status approved' do
      resource = Resource.create name: 'Resource', description: 'Description of Resource'
      from = Time.utc(2013, 1, 1)
      to = Time.utc(2013, 1, 3)
      book = Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
      book.update status: :approved
      Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
      resource.bookings_approved.first.status.must_equal 'approved'
    end
  end
  describe '#bookings_since_to' do
    describe 'When exist reserve whithin the range' do
      it 'Should return collect bookings with n element' do
        resource = Resource.create name: 'Resource', description: 'Description of Resource'
        from = Time.utc(2013, 1, 1)
        to = Time.utc(2013, 1, 2)
        Booking.create(start: from, end: to, user: 'user@gmail.com', resource: resource)
        Booking.create(start: from + 2.day, end: to + 4.day, user: 'user@gmail.com', resource: resource)
        Booking.create(start: from + 9.day, end: to + 18.day, user: 'user@gmail.com', resource: resource)
        to = Time.utc(2013, 1, 15)
        resource.bookings_since_to(from, to).size.must_equal 2
      end
    end
  end

end
