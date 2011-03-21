require 'spec_helper'

describe AthenaPerson do
  subject { Factory(:athena_person) }

  it { should be_valid }
  it { should respond_to :email }

  it "should not be valid without an email address" do
    subject.email = nil
    subject.should_not be_valid
  end

  it "should return the user with a matching athena_id" do
    subject = Factory(:athena_person_with_id)
    user = Factory(:user, :athena_id => subject.id)
    subject.user.should eq user
  end

  describe "#find_by_email_and_organization" do
    let(:organization) { Factory(:organization) }

    before(:each) do
      AthenaPerson.stub(:find).and_return
    end

    it "should search for the Person by email address and organization" do
      params = {
        :email => "eqperson@example.com",
        :organizationId => "eq#{organization.id}"
      }
      AthenaPerson.should_receive(:find).with(:first, :params => params)
      AthenaPerson.find_by_email_and_organization("person@example.com", organization)
    end

    it "should return nil if it doesn't find anyone" do
      email = "person@example.com"
      FakeWeb.register_uri(:get, "http://localhost/payments/transactions/settle", :body => '[]')
      p = AthenaPerson.find_by_email_and_organization(email, organization)
      p.should eq nil
    end
  end

  describe "organization" do
    it { should respond_to :organization }
    it { should respond_to :organization_id }
  end

end
