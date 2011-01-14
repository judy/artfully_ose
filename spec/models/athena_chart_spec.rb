require 'spec_helper'

describe AthenaChart do
  subject { Factory(:athena_chart) }

  it { should be_valid }

  it { should respond_to :name }
  it { should respond_to :sections }
  it { should respond_to :producer_pid }
  it { should respond_to :is_template }

  it "should create a default based on an event" do
    @event = Factory(:athena_event)
    @chart = AthenaChart.default_chart_for(@event)

    @chart.name.should eq AthenaChart.get_default_name(@event.name)
    @chart.event_id.should eq @event.id
    @chart.id.should eq nil
  end

  it "should get charts for an event" do
    @event = Factory(:athena_event)
    @event.id = '46'
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?eventId=eq#{@event.id}", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_event(@event)
  end

  it "should get charts for a producer" do
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?producerPid=eq50", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_by_producer('50')
  end

  it "should get templates for a producer" do
    FakeWeb.register_uri(:get, "http://localhost/stage/charts/.json?producerPid=eq50&isTemplate=eqtrue", :body => "[#{subject.encode}]" )
    @charts = AthenaChart.find_templates_by_producer('50')
  end

  describe "sections" do
    it "should not include sections in the encoded output" do
      subject.sections = []
      subject.sections << Factory(:athena_section)
      subject.encode.should_not match /"sections":/
    end
  end

  describe "#dup!" do
    before(:each) do
      subject.sections = 2.times.collect { Factory(:athena_section) }
      @copy = subject.dup!
    end

    it "should not have the same id as the original" do
      @copy.id.should_not eq subject.id
    end

    it "should have the same name as the original" do
      @copy.name.should eq subject.name
    end

    it "should have the same producer pid" do
      @copy.producer_pid.should eq subject.producer_pid
    end

    describe "and sections" do
      it "should have the same number of sections as the original" do
        @copy.sections.size.should eq subject.sections.size
      end

      it "should copy each sections name" do
        @copy.sections.collect { |section| section.name }.should eq subject.sections.collect { |section| section.name }
      end

      it "should copy each sections price" do
        @copy.sections.collect { |section| section.price }.should eq subject.sections.collect { |section| section.price }
      end

      it "should copy each sections capacity" do
        @copy.sections.collect { |section| section.capacity }.should eq subject.sections.collect { |section| section.capacity }
      end
    end
  end
end