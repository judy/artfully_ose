require 'spec_helper'

describe Item do
  disconnect_sunspot
  subject { FactoryGirl.build(:item) }

  it "is not valid with an invalid product type" do
    subject.product_type = "SomethingElse"
    subject.should_not be_valid
  end
  
  it "should report total_proce as the price plus the nongift_amount" do
    item = FactoryGirl.build(:fa_item)
    item.price.should eq 5000
    item.nongift_amount.should eq 400
    item.total_price.should eq 5400
  end
  
  describe "#order" do
    it "fetches the order form the remote" do
      subject.order.should be_an Order
      subject.order.id.should eq subject.order_id
    end
  
    it "returns nil if the order_id is not set" do
      subject.order = subject.order_id = nil
      subject.order.should be_nil
    end
  end
  
  describe ".for" do
    let(:product) { FactoryGirl.build(:ticket) }
    subject { Item.for(product, lambda { |item| item.realized_price * 0.035 }) }
  
    it { should be_an Item }
  
    it "references the product passed in" do
      subject.product.should eq product
    end
  
    it "sets the price to the price of the ticket" do
      subject.price.should eq product.price
    end
  
    it "sets itself to purchased" do
      subject.state.should eq "purchased"
    end
  
    it "sets the realized price to the price of the ticket" do
      subject.realized_price.should eq(product.price - product.class.fee)
    end
  
    it "sets the net to whatever lambda was passed in to calculate the processing" do
      realized = (product.price - product.class.fee)
      net = (realized - (0.035 * realized)).floor
      subject.net.should eq net
    end
  end
  
  describe "#product=" do
    let(:product) { FactoryGirl.build(:ticket) }
    before(:each) do 
      subject.per_item_processing_charge = lambda { |item| item.realized_price * 0.035 }
      subject.product = product
    end
  
    it "sets the product_id to the product.id" do
      subject.product_id.should eq product.id
    end
  
    it "sets the product_type to the product class" do
      subject.product_type.should eq product.class.to_s
    end
  
    context "a donation" do
      let(:donation) { FactoryGirl.build(:donation) }
      before(:each) { subject.product = donation }
  
      it "sets the price to the price of the donation" do
        subject.price.should eq donation.price
      end
  
      it "sets the realized price to the price of the donation" do
        subject.realized_price.should eq donation.price
      end
  
      it "sets the net to 3.5% of the realized price" do
        net = (donation.price - (0.035 * donation.price)).floor
        subject.net.should eq net
      end
    end
  end
  
  describe "a ticket" do
    let(:ticket) { FactoryGirl.build(:ticket) }
    subject { Item.new }
    before(:each) do
      subject.per_item_processing_charge = lambda { |item| item.realized_price * 0.035 }
      subject.product = ticket
    end
  
    it "sets the show_id to the tickets show id" do
      subject.show_id.should eq ticket.show_id
    end
  
    it "sets the price to the price of the ticket" do
      subject.price.should eq ticket.price
    end
  
    it "sets itself to purchased" do
      subject.state.should eq "purchased"
    end
  
    it "sets the realized price to the price of the ticket" do
      subject.realized_price.should eq(ticket.price - ticket.class.fee)
    end
  
    it "sets the net to whatever lambda was passed in to calculate the processing" do
      realized = (ticket.price - ticket.class.fee)
      net = (realized - (0.035 * realized)).floor
      subject.net.should eq net
    end
  end
  
  describe "#ticket?" do
    subject { FactoryGirl.build(:item, :product => FactoryGirl.build(:sold_ticket)) }
    it { should be_a_ticket }
  end
  
  describe "#donation?" do
    subject { FactoryGirl.build(:item, :product => FactoryGirl.build(:donation)) }
    it { should be_a_donation }
  end
  
  describe "#dup!" do
    it "creates a duplicate item without the id and state" do
      old_attr = subject.attributes.dup
      Item.should_receive(:new).with(old_attr.reject { |key, value| %w( id state ).include? key })
      subject.dup!
    end
  end
  
  describe "#refundable?" do
    context "when already modified" do
      it "is not true if it has already been refunded" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_refundable
      end
    end
  
    context "when not yet modified" do
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)
  
        subject.product.stub(:refundable?).and_return(true)
        subject.should be_refundable
  
        subject.product.stub(:refundable?).and_return(false)
        subject.should_not be_refundable
      end
    end
  end
  
  describe "#exchangeable?" do
    context "when already modified" do
      it "is not true if it has already been exchanged" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_exchangeable
      end
    end
  
    context "when not yet modified" do
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)
  
        subject.product.stub(:exchangeable?).and_return(true)
        subject.should be_exchangeable
  
        subject.product.stub(:exchangeable?).and_return(false)
        subject.should_not be_exchangeable
      end
    end
  end
  
  describe "#returnable?" do
    context "when already modified" do
      it "is not true if it has already been returned" do
        subject.stub(:modified?).and_return(true)
        subject.should_not be_returnable
      end
    end
  
    context "when not yet modified" do
      it "relies on the product" do
        subject.stub(:modified?).and_return(false)
  
        subject.product.stub(:returnable?).and_return(true)
        subject.should be_returnable
  
        subject.product.stub(:returnable?).and_return(false)
        subject.should_not be_returnable
      end
    end
  end
  
  describe "#modified?" do
    %w( purchased comped ).each do |state|
      it "is not considered modified it is #{state}" do
        subject.state = state
        subject.should_not be_modified
      end
    end
  end
  
  describe "#to_refund" do
    it "operates on a duplicate item" do
      subject.to_refund.id.should be_nil
    end
  
    it "returns an item with the refund price set" do
      subject.to_refund.price.should eq subject.price * -1
      subject.to_refund.realized_price.should eq subject.realized_price * -1
      subject.to_refund.net.should eq subject.net * -1
    end
  end
  
  describe "#return!" do
    context "with tickets" do
      it "returns the product to inventory if it is returnable" do
        subject.product.stub(:returnable?).and_return(true)
        subject.product.should_receive(:return!)
        subject.return!
      end
  
      it "does not return the product if it is not returnble" do
        subject.product.stub(:returnable?).and_return(false)
        subject.product.should_not_receive(:return!)
        subject.return!
      end
    end
  end
end