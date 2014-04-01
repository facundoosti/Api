  require File.expand_path(File.join('test', 'test_helper'))
  require 'validator'

  describe '#valid_date?' do
    describe 'when argument is a String' do
      it "should return true if it satisfies the condition 'YYYY-MM-DD'" do
        Validator.valid_date?('2013-22-22').must_equal true
      end
      it "should return false if it's not satisfies the condition 'YYYY-MM-DD'" do
        Validator.valid_date?('2013-22--22').wont_equal true
      end
        it "should return false if it's not satisfies the condition 'YYYY-MM-DD'" do
        Validator.valid_date?('2013-22-22-21').must_equal false
      end
      it "should return false if it's not number" do
        Validator.valid_date?('2013-22-2L').wont_equal true
      end
    end
  end
