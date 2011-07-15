Feature: User registration
  In order to use the application
  a user wants to be able to register

  Background:
    Given I can save People to ATHENA

  @wip
  Scenario: Register as a producer
    Given I am on the new user registration page
    When I fill in "Email" with "example@example.com"
    And I fill in "Password" with "password"
    And I fill in "Retype Password" with "password"
    And I check "user_user_agreement"
    And I press "Sign up"
    Then I should be on the dashboard page

  @wip
  Scenario: A producer should not be able to register without accepting the user agreement
    Given I am on the new user registration page
    When I fill in "Email" with "example@example.com"
    And I fill in "Password" with "password"
    And I fill in "Retype Password" with "password"
    And I press "Sign up"
    Then I should see "User agreement must be accepted"