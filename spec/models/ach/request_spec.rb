require 'spec_helper'

describe ACH::Request do
  let(:customer)    { Factory(:ach_customer) }
  let(:account)     { Factory(:ach_account) }
  let(:transaction) { ACH::Transaction.new(123400, "Test Transaction") }
  subject { ACH::Request.new(transaction, customer, account) }

  describe ".for" do
    let(:recipient) do
      mock(:bank_account).tap do |ba|
        ba.stub(:customer_information).and_return({
          :id      => 1,
          :name    => "Joe Smith",
          :address => "1 Westward Way",
          :city    => "New York",
          :state   => "NY",
          :zip     => "12345",
          :phone   => "1231231234"
        })

        ba.stub(:account_information).and_return({
          :routing_number => "123412345",
          :number         => "78907890789",
          :type           => "Checking"
        })
      end
    end

    it "creates a new request with the amount set" do
      ACH::Request.for(2500, recipient).transaction.amount.should eq "25.00"
    end

    it "uses the recipient to set up the customer" do
      recipient.should_receive(:customer_information)
      ACH::Request.for(2500, recipient).transaction.amount.should eq "25.00"
    end

    it "uses the account information to set up the account" do
      recipient.should_receive(:account_information)
      ACH::Request.for(2500, recipient).transaction.amount.should eq "25.00"
    end
  end

  describe "#new" do
    it "should store a reference to the required information" do
      subject.customer.should eq customer
      subject.account.should eq account
      subject.transaction.should eq transaction
    end
  end

  describe "#serialize" do
    it "should join the seralized hashes from transaction, customer, account" do
      query_hashes = [ transaction, customer, account ].collect(&:serializable_hash).reduce(:merge)
      query_string = ACH::Request::CREDENTIALS.merge(query_hashes).to_query
      subject.serialize.should eq query_string
    end
  end

  describe "#submit" do
    it "submits a GET request to First ACH" do
      FakeWeb.register_uri(:get, %r|https://demo.firstach.com/https/TransRequest\.asp?.*|, :body => "")
      subject.submit
      FakeWeb.last_request.path.should match %r|https://demo.firstach.com/https/TransRequest.asp?.*|
      FakeWeb.last_request.method.should == "GET"
    end
  end
end
