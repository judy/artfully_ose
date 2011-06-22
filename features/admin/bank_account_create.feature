Feature: Bank Account Creation
  In order to receive payment via the ACH API, organizations must have
  bank account information on file. An admin can add information to an organization.

  Background:
    Given I am logged in as an admin
    And an organization exists with an name of "Fractured Atlas"
    And I follow "Organizations"
    And I follow "Fractured Atlas"


  Scenario: An admin adds a bank account to an organization
    Given I follow "Add a Bank Account"
    When I fill in the following:
      | Routing number | 111111118            |
      | Number         | 32152401253215240125 |
      | Account type   | Personal Checking    |
      | Name           | Joe Smith            |
      | Address        | 248 W 35th St        |
      | City           | New York             |
      | State          | NY                   |
      | Zip            | 12345                |
      | Phone          | 123-789-4568         |
    And I press "Create"
    Then I should see "Added a bank account to Fractured Atlas"
    And the organization "Fractured Atlas" should have a bank account

  Scenario: An admin attempts to add a new bank account without fields
    Given I follow "Add a Bank Account"
    And I press "Create"
    And the organization "Fractured Atlas" should not have a bank account
