Feature: Thread-specific pseudonyms
  As a student who values anonymity
  I want each thread to display a unique pseudonym for my account
  So that my identity stays hidden while conversations remain consistent

  Scenario: Comment pseudonym matches the thread-specific handle
    Given a user exists with email "thread_owner@example.com" and password "Password123!"
    And I sign in with email "thread_owner@example.com" and password "Password123!"
    When I create a post titled "Need CPT forms" with body "Looking for advice on CPT paperwork."
    And I sign out
    Given a user exists with email "thread_commenter@example.com" and password "Password123!"
    And I sign in with email "thread_commenter@example.com" and password "Password123!"
    And I visit the post titled "Need CPT forms"
    And I leave a comment "Following for details!"
    And I sign out
    Given a user exists with email "observer@example.com" and password "Password123!"
    And I sign in with email "observer@example.com" and password "Password123!"
    And I visit the post titled "Need CPT forms"
    Then I should see the thread pseudonym for "thread_commenter@example.com" on "Need CPT forms"
    And I should not see "thread_commenter@example.com" in the comments list
