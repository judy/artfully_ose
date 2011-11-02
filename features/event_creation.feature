Feature: Event creation
  In order to create a event and its tickets
  a producer wants to be able to create a new event and have tickets generated from its details

  Scenario: A producer creates a new event
    Given I am logged in
    And I am part of an organization with access to the ticketing kit
    And I am on the new event page
    When I fill in the following event details:
    | name      | venue      | city     | state | producer      |
    | Some Name | Some Venue | New York | NY    | Some Producer |
    And I press "Create Event"
    And I should see "Some Name"
    And I should see "Some Venue"
    And I should see "New York, NY"
