Given /^I peep statements$/ do
  Given %{I am on the root page}
  And %{I follow "Statements"}
end

Then /^I should see a statement$/ do
  page.should have_content("Statement Report:")
end

Then /^I should see a list of events$/ do
  page.should have_xpath("//ul[@id='event-list']/li", :count => 1)
  page.should have_content("The Walking Dead")
end