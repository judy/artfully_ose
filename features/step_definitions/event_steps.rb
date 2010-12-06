Given /^the following event exists with (\d+) performance for producer with id of (\d+):$/ do |performance_count, producer_id, table|
  event = Factory(:athena_event, table.hashes.first)
  FakeWeb.register_uri(:any, "http://localhost/stage/events/#{event.id}.json", :status => 200, :body => event.encode)
  FakeWeb.register_uri(:get, "http://localhost/stage/events/.json?producerId=eq#{producer_id}", :status => 200, :body => "[#{event.encode}]")

  performances = "["
  performance_count.to_i.times do
    performances << Factory(:athena_performance, :event_id => event.id).encode
  end
  performances << "]"

  FakeWeb.register_uri(:get, "http://localhost/stage/performances/.json?eventId=eq#{event.id}", :status => 200, :body => performances)
end

Then /^the response should be JSON with callback "([^"]*)" for the following events:$/ do |callback, table|
  events = []
  table.hashes.each do |hash|
    events << Factory(:athena_event, hash)
  end

  body = /#{callback}\((.*)\);/.match(last_response.body)
  content = JSON.parse(body[1])
  event = Factory(:athena_event, content)
  event.should == events.first
end
