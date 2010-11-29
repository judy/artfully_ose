Feature: Producer Activation
  In order to use producer features
  a user wants wants to be able to activate producer features

  Background:
    Given I can save Credit Cards to ATHENA

  Scenario: A user can get to the producer activation page
    Given I am logged in as a "patron"
    And I follow "Dashboard"
    When I follow "Producer Activation"
    Then I should see "Become a Producer"
    And I should see "Please enter your credit card information"

  Scenario: A user enters their credit card to become a producer
    Given I am logged in
    And I follow "Dashboard"
    And I follow "Producer Activation"
    And I can save Customers to ATHENA
    When I fill in "Cardholder Name" with "Joe Producer"
    And I fill in "Number" with "4111111111111111"
    And I fill in "CVV" with "123"
    And I fill in "First Name" with "Joe"
    And I fill in "Last Name" with "Producer"
    And I fill in "Email" with "joe.producer@example.com"
    And I fill in "Phone" with "1231231234"
    And I fill in "Organization" with "Some Organization"
    And I press "Submit"
    Then I should see "Congratulations! You now have access to producer features"