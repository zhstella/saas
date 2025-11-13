Feature: Respond to a question
  As a community member with helpful advice
  I want to leave an anonymous answer on a question
  So that I can guide classmates quickly

  Background:
    Given a post titled "Applying for CPT" exists

  Scenario: Logged in student replies to a post
    Given a user exists with email "mentor@example.com" and password "Password123!"
    And I sign in with email "mentor@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I leave an answer "Bring your updated I-20 to the appointment."
    Then I should see "Answer added."
    And I should see "Bring your updated I-20 to the appointment." in the answers list

  Scenario: Missing answer body shows validation errors
    Given a user exists with email "helper@example.com" and password "Password123!"
    And I sign in with email "helper@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I submit an empty answer
    Then I should see "Body can't be blank"

  Scenario: Guest must log in before replying
    When I sign out
    And I visit the post titled "Applying for CPT"
    Then I should see "LOG IN WITH UNIVERSITY SSO"

  Scenario: Answer author deletes their response
    Given a user exists with email "deleter@example.com" and password "Password123!"
    And I sign in with email "deleter@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I leave an answer "Here is the paperwork checklist."
    And I delete the most recent answer
    Then I should see "Answer deleted."
    And I should not see "Here is the paperwork checklist." in the answers list

  Scenario: Only the author can delete their answer
    Given a user exists with email "answer_owner@example.com" and password "Password123!"
    And I sign in with email "answer_owner@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I leave an answer "I'll share my advisor's notes."
    And I sign out
    Given a user exists with email "bystander@example.com" and password "Password123!"
    And I sign in with email "bystander@example.com" and password "Password123!"
    And I visit the post titled "Applying for CPT"
    When I attempt to delete the most recent answer without permission
    Then I should see the alert "You do not have permission to perform this action."
    And I should see "I'll share my advisor's notes." in the answers list

  Scenario: Students comment on answers
    Given a user exists with email "answerer@example.com" and password "Password123!"
    And I sign in with email "answerer@example.com" and password "Password123!"
    When I visit the post titled "Applying for CPT"
    And I leave an answer "Bring your updated I-20."
    And I sign out
    Given a user exists with email "commenter@example.com" and password "Password123!"
    And I sign in with email "commenter@example.com" and password "Password123!"
    And I visit the post titled "Applying for CPT"
    And I comment "Thanks for clarifying!" on the most recent answer
    Then I should see "Thanks for clarifying!" in the answers list
