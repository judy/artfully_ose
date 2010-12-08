require 'spec_helper'

describe AthenaTicket do

  describe "attributes" do
    subject { Factory(:ticket) }

    it { should respond_to :event }
    it { should respond_to :venue }
    it { should respond_to :performance }
    it { should respond_to :sold }
    it { should respond_to :price }
  end

  describe "#find" do
    it "fetch a ticket by ID" do
      @fake_ticket = Factory(:ticket_with_id)
      @ticket = AthenaTicket.find(@fake_ticket.id)
      @ticket.should_not be_nil
      @ticket.should eq @fake_ticket
      @ticket.should be_valid
    end

    it "should raise ForbiddenAccess when attempting to fetch all tickets" do
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json", :status => "403")
      lambda { AthenaTicket.all }.should raise_error(ActiveResource::ForbiddenAccess)
    end

    it "should raise ResourceNotFound for invalid IDs" do
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/0.json", :status => ["404", "Not Found"])
      lambda { AthenaTicket.find(0) }.should raise_error(ActiveResource::ResourceNotFound)
    end

    it "should generate a query string for a single parameter search" do
      @ticket = Factory(:ticket, :price => 50)
      FakeWeb.register_uri(:get, "http://localhost/tix/tickets/.json?price=eq50", :body => "[#{@ticket.encode}]" )
      @tickets = AthenaTicket.find(:all, :params => {:price => "eq50"})
      @tickets.map { |ticket| ticket.price.should == 50 }
    end
  end

  describe "#destroy" do
    it "should issue a DELETE when destroying a ticket" do
      @ticket = Factory(:ticket_with_id)
      FakeWeb.register_uri(:delete, "http://localhost/tix/tickets/#{@ticket.id}.json", :status => "204")
      @ticket.destroy

      FakeWeb.last_request.method.should == "DELETE"
      FakeWeb.last_request.path.should == "/tix/tickets/#{@ticket.id}.json"
    end
  end

  describe "#save" do
    it "should issue a PUT when updating a ticket" do
      @ticket = Factory(:ticket_with_id)
      FakeWeb.register_uri(:put, "http://localhost/tix/tickets/#{@ticket.id}.json", :status => "200")
      @ticket.save

      FakeWeb.last_request.method.should == "PUT"
      FakeWeb.last_request.path.should == "/tix/tickets/#{@ticket.id}.json"
    end

    it "should issue a POST when creating a new AthenaTicket" do
      FakeWeb.register_uri(:post, "http://localhost/tix/tickets/.json", :status => "200")
      @ticket = Factory.create(:ticket)

      FakeWeb.last_request.method.should == "POST"
      FakeWeb.last_request.path.should == "/tix/tickets/.json"
    end
  end

  describe "searching"do
    it "by performance" do
      FakeWeb.register_uri(:get, %r|http://localhost/tix/tickets/.json\?|, :status => "200", :body => "[]")
      now = DateTime.now
      params = { :performance => "eq#{now.as_json}" }
      AthenaTicket.search(params)
      FakeWeb.last_request.path.should == "/tix/tickets/.json?performance=eq#{CGI::escape now.as_json}"

    end

    it "should add _limit to the query string when included in the arguments" do
      FakeWeb.register_uri(:get, 'http://localhost/tix/tickets/.json?_limit=10', :status => "200", :body => "[]")
      params = { :limit => "10" }
      AthenaTicket.search(params)
      FakeWeb.last_request.path.should == "/tix/tickets/.json?_limit=10"
    end
  end
end
