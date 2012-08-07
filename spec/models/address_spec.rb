require 'spec_helper'

describe Address do
  disconnect_sunspot

  let(:keys) { [ :address1, :address2, :city, :state, :zip, :country ] }
  let(:aaaa) { kv = Hash.new; for k in keys do kv[k] = 'a' end; kv }
  let(:bbbb) { kv = Hash.new; for k in keys do kv[k] = 'b' end; kv }
  subject { FactoryGirl.build(:address, aaaa) }
  let(:addra) { FactoryGirl.build(:address, aaaa) }
  let(:addrb) { FactoryGirl.build(:address, bbbb) }

  describe "find_or_create" do
    it "should create a new address is none is found for a given person" do
      person = FactoryGirl.build(:person)
      address = Address.find_or_create(person.id)
      address.should_not be_nil
      address.person.should eq person
    end
    
    it "should return the existing address if it exists" do
      person = FactoryGirl.build(:person)
      address = FactoryGirl.build(:address, :person_id => person.id)     
      Address.should_not_receive(:create)
      existing_address = Address.find_or_create(person.id)
      existing_address.should eq address
    end
  end

  context "is_same_as()" do
    RSpec::Matchers.define :be_the_same_as do |addr|
      match do |subj|
        subj.is_same_as(addr)
      end
    end

    it "should be true for subject" do
      should be_the_same_as(subject)
    end

    it "should be true for a carbon copy" do
      should be_the_same_as(addra)
    end

    it "should be false for a different address" do
      should_not be_the_same_as(addrb)
    end

    it "should be false for any slightly different address" do
      for key in keys do
        addrx = addra.clone
        addrx[key] = 'x'
        addrx.should be_the_same_as(addrx)
        should_not be_the_same_as(addrx)
      end
    end

  end
end