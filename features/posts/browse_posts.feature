Feature: Browse campus conversations
  As a Columbia/Barnard student
  I want to see recent questions and conversations after logging in
  So that the feed stays limited to verified peers

  Background:
    Given the following posts exist:
      | title                 | body                                             |
      | Housing after finals  | Does anyone have tips for summer sublets?        |
      | Visa renewal clinic   | What documents should I prepare for ISSO visits? |

  Scenario: Viewing recent posts on the homepage
    Given a user exists with email "reader@example.com" and password "Password123!"
    And I sign in with email "reader@example.com" and password "Password123!"
    When I visit the home page
    Then I should see "Housing after finals" in the posts list
    And I should see "Visa renewal clinic" in the posts list

  Scenario: Searching filters posts without leaking identities
    Given a user exists with email "searcher@example.com" and password "Password123!"
    And I sign in with email "searcher@example.com" and password "Password123!"
    When I search for "visa"
    Then I should see "Visa renewal clinic" in the posts list
    And I should not see "Housing after finals" in the posts list
    And the posts list should not reveal email addresses

  Scenario: Submitting an empty search shows a helpful alert
    Given a user exists with email "blanksearch@example.com" and password "Password123!"
    And I sign in with email "blanksearch@example.com" and password "Password123!"
    When I submit an empty search
    Then I should see the alert "Please enter text to search."

  Scenario: Guest visitors are asked to log in first
    When I visit the home page
    Then I should see "LOG IN WITH UNIVERSITY SSO"

  Scenario: Expired posts are hidden from the feed
    Given a user exists with email "active@example.com" and password "Password123!"
    And an expired post titled "Old roommates" exists
    And I sign in with email "active@example.com" and password "Password123!"
    When I visit the home page
    Then I should not see "Old roommates" in the posts list
