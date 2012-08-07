require 'spec_helper'
require 'active_merchant_test_helper'

describe Cart do
  disconnect_sunspot
  include ActiveMerchantTestHelper
  subject { FactoryGirl.build(:cart) }

  it "should be marked as unfinished in the started state" do
    subject.state = :started
    subject.should be_unfinished
  end

  it "should be marked as unfinished in the rejected state" do
    subject.state = 'rejected'
    subject.should be_unfinished
  end

  describe "with items" do
    it { should respond_to :items }

    it "should be empty without any items" do
      subject.should be_empty
    end
  end

  describe "#total" do
    let(:items) { 10.times.collect{ mock(:item, :price => 10) }}
    it "should sum up the price of the tickets via total" do
      subject.stub(:items) { items }
      subject.total.should eq 100
    end
  end

  describe "ticket fee" do
    let(:tickets) { 2.times.collect { FactoryGirl.build(:ticket) } }
    let(:free_tickets) { 2.times.collect { FactoryGirl.build(:free_ticket) } }

    it "should have a fee of 0 if there are no tickets" do
      subject.fee_in_cents.should eq 0
    end

    it "should have a fee of 0 if there are free tickets" do
      subject << free_tickets
      subject.fee_in_cents.should eq 0
      subject << tickets
      subject.fee_in_cents.should eq 400
    end

    it "should keep the fee updated while tickets are added" do
      subject << tickets
      subject.fee_in_cents.should eq 400
    end

    it "should have a 0 fee if there is a donation" do
      donation = FactoryGirl.build(:donation)
      subject.donations << donation
      subject.fee_in_cents.should eq 0
      subject << tickets
      subject.fee_in_cents.should eq 400
    end

    it "should include the fee in the total" do
      subject << tickets
      subject.fee_in_cents.should eq 400
      subject.total.should eq 10400
    end
  end

  describe "#pay_with" do
    let(:payment) { mock(:payment, :amount => 100) }

    it "saves the cart after payment" do
      payment.stub(:requires_authorization?) { false }
      subject.should_receive(:save!)
      subject.pay_with(payment)
    end

    describe "authorization" do
      it "attempt to authorize the payment if required" do
        payment.stub(:requires_authorization?) { true }
        payment.should_receive(:purchase).and_return(successful_response)
        subject.pay_with(payment)
      end

      it "does not attempt to authorize the payment if it is not required" do
        payment.stub(:requires_authorization?).and_return(false)
        payment.should_not_receive(:purchase)
        subject.pay_with(payment)
      end
    end

    describe "state transitions" do
      it "should transition to approved when the payment is approved" do
        payment.stub(:requires_authorization?).and_return(true)
        payment.stub(:purchase).and_return(successful_response)
        subject.pay_with(payment)
        subject.should be_approved
      end

      it "should tranisition to rejected when the Payment is rejected" do
        payment.stub(:requires_authorization?).and_return(true)
        payment.stub(:purchase).and_return(fail_response)
        subject.pay_with(payment)
        subject.should be_rejected
      end

      it "should transition to approved if no authorization is required for the payment" do
        payment.stub(:requires_authorization?).and_return(false)
        subject.pay_with(payment)
        subject.should be_approved
      end
    end
  end

  describe "#finish" do
    subject { FactoryGirl.build(:cart_with_items) }

    it "should mark each item as sold" do
      subject.tickets.each { |ticket| ticket.should_receive(:sell_to) }
      subject.finish(FactoryGirl.build(:person), Time.now)
    end

    it "should send a metric" do
      RestfulMetrics::Client.should_receive(:add_compound_metric).with(ENV["RESTFUL_METRICS_APP"], "sale_complete", ["$100 - $249.99"])
      subject.finish(FactoryGirl.build(:person), Time.now)
    end
  end

  describe "organizations" do
    it "includes the organizations for the included donations" do
      donation = FactoryGirl.build(:donation)
      subject.donations << donation
      subject.organizations.should include donation.organization
    end

    it "includes the organizations for the included tickets" do
      ticket = FactoryGirl.build(:ticket)

      subject.tickets << ticket
      subject.organizations.should include ticket.organization
    end
  end

  describe ".clear_donations" do
    it "should do nothing when there are no donations" do
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 0
    end

    it "should clear when there is one donation" do
      donation = FactoryGirl.build(:donation)
      subject.donations << donation
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 1
      donations.first.should eq donation
    end

    it "should clear when there are two donations" do
      donation = FactoryGirl.build(:donation)
      donation2 = FactoryGirl.build(:donation)
      subject.donations << donation
      subject.donations << donation2
      donations = subject.clear_donations
      subject.donations.size.should eq 0
      donations.size.should eq 2
      donations.first.should eq donation
      donations[1].should eq donation2
    end
  end

  describe ".generate_donations" do
    let(:tickets) { 2.times.collect { FactoryGirl.build(:ticket) } }
    let(:organizations) { tickets.collect(&:organization) }

    before(:each) do
      organizations.each do |org|
        org.kits << RegularDonationKit.new(:state => :activated)
      end
    end

    it "should return a donation for the producer of a single ticket in the cart" do
      subject.tickets << tickets
      donations = subject.generate_donations
      donations.each do |donation|
        organizations.should include donation.organization
      end
    end

    it "should not return any donations if there are no tickets" do
      subject.generate_donations.should be_empty
    end

    it "should return one donation if the tickets are for the same producer" do
      tickets.each { |ticket| ticket.organization = organizations.first }
      subject.stub(:tickets).and_return(tickets)
      subject.generate_donations.should have(1).donation
    end
  end

  describe ".can_hold?" do
    let(:ticket) { Factory :ticket }
    let(:cart) { Factory :cart }

    it "should be able to hold another ticket" do
      cart.should be_can_hold ticket
    end
  end
end