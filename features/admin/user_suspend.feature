Feature: User suspension
  In order to moderate the application
  an admin wants to be able to suspend users

  Scenario: An admin searches for a user to suspend
    Given I am logged in as an admin
    And I am on the admin root page
    And a user exists with an email of "user@example.com"
    And I am on the admin users page
    And I fill in "query" with "user@example.com"
    And I press "Search"
    Then I should see "user@example.com"

  Scenario: An admin suspends a user
    Given I am logged in as an admin
    And I am on the admin users page
    And I have found the user "user@example.com" to suspend
    When I fill in "Reason" with "Testing the suspension feature."
    And I press "Suspend"
    Then I should see "Suspended user@example.com"
    And I should see "Reason: Testing the suspension feature."
