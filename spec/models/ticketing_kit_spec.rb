require 'spec_helper'

describe TicketingKit do
  subject { Factory(:ticketing_kit) }

  describe "state machine" do
    it { should respond_to :cancel }
    it { should respond_to :cancelled? }
    it { should respond_to :activated? }


    it "should start in the new state" do
      subject.should be_new
    end

    it "should not transition to activated if the user does not have a credit card" do
      subject.user.stub!(:credit_cards).and_return([])
      subject.activate!
      subject.should_not be_activated
    end

    it "should change from activated to cancelled when cancelled" do
      subject.state = :activated
      subject.cancel!
      subject.should be_cancelled
    end

    it "should call on_activate when transitioning" do
      subject.stub(:on_activate)
      subject.stub(:activatable?).and_return(true)
      subject.should_receive(:on_activate)
      subject.activate!
    end

    it "should grant the role of producer to the user on activation" do
      subject.stub(:activatable?).and_return(true)
      subject.activate
      subject.user.should have_role(:producer)
    end
  end

  describe ".valid?" do
    it "should be valid with a valid user" do
      subject.user.should be_valid
      subject.should be_valid
    end

    it "should not be valid unless associated with a user" do
      subject.stub(:user).and_return(nil)
      subject.should_not be_valid
    end

    it "should be valid if the user has at least one credit card" do
      subject.user.credit_cards << Factory(:credit_card)
      subject.should be_valid
    end
  end
end