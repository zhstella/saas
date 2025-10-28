Feature: Ask a new question
  As a verified student
  I want to author an anonymous question
  So that the community can help me

  Scenario: Authenticated student creates a post
    Given I register with email "student1@example.com" and password "Password123!"
    When I create a post titled "Looking for roommates" with body "Anyone searching for off-campus roommates for fall?"
    Then I should see "Post was successfully created!"
    And I should see "Looking for roommates" on the page
    And I should see "Anyone searching for off-campus roommates for fall?"
