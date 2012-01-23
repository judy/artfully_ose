Feature: Exchange Tickets
  In order to provide customer service to patrons
  a producer wants to be able to exchange a set of tickets for
  an equal amount of other tickets

  Background:
    Given I am logged in
    And I am part of an organization
    And there is an event with 3 shows
    And the 1st show has had tickets created
    And the 1st show is on sale

  Scenario: A producer starts the exchange workflow by selecting tickets
    Given there is an order with 2 tickets
    When I check the 1st ticket for an exchange
    And I press "Exchange"
    Then I should see "Exchanging Tickets"

  Scenario: A producer selects the tickets to exchange
    Given I have found 2 items to exchange
    When I select the 1st event
    And I select the 1st show
    And I select the 1st section
    And I check 2 tickets
    And I press "Exchange these tickets"
    Then I should see "Successfully exchanged 2 tickets"

  Scenario: A producer selects a comped ticket to exchange
    Given there is an order with 2 comps
    Then there should not be any tickets available to exchange

  Scenario: A producer selects fewer tickets than required for an exchange.
    Given I have found 3 items to exchange
    When I select the 1st event
    And I select the 1st show
    And I select the 1st section
    And I check 2 tickets
    And I press "Exchange these tickets"
    Then I should see "Unable to process exchange."