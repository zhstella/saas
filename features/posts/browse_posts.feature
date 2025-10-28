Feature: Browse campus conversations
  As a Columbia student browsing anonymously
  I want to see recent questions and conversations
  So that I can learn from my peers without logging in

  Background:
    Given the following posts exist:
      | title                 | body                                             |
      | Housing after finals  | Does anyone have tips for summer sublets?        |
      | Visa renewal clinic   | What documents should I prepare for ISSO visits? |

  Scenario: Viewing recent posts on the homepage
    When I visit the home page
    Then I should see "Housing after finals" in the posts list
    And I should see "Visa renewal clinic" in the posts list

  Scenario: Searching filters posts without leaking identities
    When I search for "visa"
    Then I should see "Visa renewal clinic" in the posts list
    And I should not see "Housing after finals" in the posts list
    And the posts list should not reveal email addresses
