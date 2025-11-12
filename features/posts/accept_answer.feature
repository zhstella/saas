Feature: Accept answers and lock threads
  As the author of a question
  I want to accept the best answer and lock the thread
  So everyone knows the solution and duplicates stay closed

  Background:
    Given a user exists with email "asker@example.com" and password "Password123!"
    And a user exists with email "helper@example.com" and password "Password123!"

  Scenario: Accepting an answer locks the conversation
    Given I sign in with email "asker@example.com" and password "Password123!"
    When I create a post titled "Need housing tips" with body "How do I find sublets?"
    And I sign out
    And I sign in with email "helper@example.com" and password "Password123!"
    And I visit the post titled "Need housing tips"
    And I leave an answer "Check the verified housing channel."
    And I sign out
    And I sign in with email "asker@example.com" and password "Password123!"
    And I visit the post titled "Need housing tips"
    When I accept the most recent answer
    Then I should see "Thread locked after accepting an answer."
    And I should see "This thread is locked. No new answers can be added."
    And I should see "Accepted answer"

  Scenario: Reopening a locked thread restores the answer form
    Given I sign in with email "asker@example.com" and password "Password123!"
    When I create a post titled "Need visa tips" with body "What documents do I need?"
    And I sign out
    And I sign in with email "helper@example.com" and password "Password123!"
    And I visit the post titled "Need visa tips"
    And I leave an answer "Start with the ISSO checklist."
    And I sign out
    And I sign in with email "asker@example.com" and password "Password123!"
    And I visit the post titled "Need visa tips"
    And I accept the most recent answer
    When I reopen the thread
    Then I should see "Share Your Answer"
    And I should not see "This thread is locked. No new answers can be added."
