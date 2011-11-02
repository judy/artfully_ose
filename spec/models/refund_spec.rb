require 'spec_helper'

describe Refund do
  disconnect_sunspot
  let(:order) { Factory(:order) }
  let(:items) { 3.times.collect { Factory(:item)}}
  subject { Refund.new(order, items) }

  describe "#submit" do
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/payments/transactions/refund", :body => "{ success: true }")
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
      subject.stub(:create_refund_order)
    end

    it "should attempt to refund the payment made for the order" do
      subject.submit
      FakeWeb.last_request.method.should eq "POST"
      FakeWeb.last_request.path.should eq "/payments/transactions/refund"
    end

    it "should include the total price of all items being refunded" do
      total = subject.refund_amount / 100.0
      subject.submit
      FakeWeb.last_request.body.should match Regexp.new(/\"amount\":#{total}/)
    end
  end

  describe "refund_amount" do
    it "should return the total for the items in the refund in cents" do
      total = items.collect(&:price).reduce(:+)
      subject.refund_amount.should eq total
    end
  end

  describe "successful?" do
    before(:each) do
      subject.items.each { |i| i.stub(:return!) }
      subject.items.each { |i| i.stub(:refund!) }
      subject.stub(:create_refund_order)
    end

    it "should return false if it has not been submitted" do
      subject.should_not be_successful
    end

    it "should return true if the refund was successful" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/refund', :body => '{ "success": true }')
      subject.submit
      subject.should be_successful
    end

    it "should return false if the refund was not successful" do
      FakeWeb.register_uri(:post, 'http://localhost/payments/transactions/refund', :body => '{ "success": false }')
      subject.submit
      subject.should_not be_successful
    end
  end

end
