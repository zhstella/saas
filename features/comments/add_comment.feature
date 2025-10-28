Feature: Respond to a question
  As a community member with helpful advice
  I want to leave an anonymous comment on a question
  So that I can guide classmates quickly

  Background:
    Given a post titled "Applying for CPT" exists

  Scenario: Logged in student replies to a post
    Given a user exists with email "mentor@example.com" and password "Password123!"
    And I sign in with email "mentor@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I leave a comment "Bring your updated I-20 to the appointment."
    Then I should see "Comment added."
    And I should see "Bring your updated I-20 to the appointment." in the comments list
