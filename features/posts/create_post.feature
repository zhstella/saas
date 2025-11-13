Feature: Ask a new question
  As a verified student
  I want to author an anonymous question
  So that the community can help me

  Scenario: Authenticated student creates a post
    Given I register with email "student1@example.com" and password "Password123!"
    When I create a post titled "Looking for roommates" with body "Anyone searching for off-campus roommates for fall?"
    Then I should see "Post was successfully created!"
    And I should see "Looking for roommates" on the page
    And I open the post titled "Looking for roommates"
    Then I should see "Anyone searching for off-campus roommates for fall?"

  Scenario: Student sees errors when required fields are missing
    Given I register with email "student2@example.com" and password "Password123!"
    When I try to create a post without a title
    Then I should see "Title can't be blank"
    And I should see "Body can't be blank"

  Scenario: Guest must log in before accessing the post form
    When I visit the new post page without logging in
    Then I should see "LOG IN WITH UNIVERSITY SSO"

  Scenario: Author marks a post to expire in 7 days
    Given I register with email "temp@example.com" and password "Password123!"
    When I create an expiring post titled "Temporary tips" with body "This should disappear soon." that expires in 7 days
    And I open the post titled "Temporary tips"
    Then I should see "Expires" on the page

  Scenario: Author previews a draft before posting
    Given I register with email "previewer@example.com" and password "Password123!"
    When I preview a post titled "Need advice" with body "Does anyone recommend a fall elective?"
    Then I should see "Draft Preview"
    And I should see "Does anyone recommend a fall elective?" on the page
