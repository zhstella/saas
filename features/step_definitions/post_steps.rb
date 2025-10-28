Given('the following posts exist:') do |table|
  table.hashes.each do |row|
    create(:post, title: row['title'], body: row['body'])
  end
end

Given('a post titled {string} exists') do |title|
  create(:post, title: title, body: 'Placeholder body for feature spec')
end

Given('a user exists with email {string} and password {string}') do |email, password|
  create(:user, email: email, password: password, password_confirmation: password)
end

Given('I register with email {string} and password {string}') do |email, password|
  visit new_user_registration_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  fill_in 'Password confirmation', with: password
  click_button 'Sign up'
end

Given('I sign in with email {string} and password {string}') do |email, password|
  visit new_user_session_path
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log in'
end

When('I visit the home page') do
  visit root_path
end

When('I search for {string}') do |query|
  visit root_path
  fill_in 'Search', with: query
  click_button 'Search'
end

When('I create a post titled {string} with body {string}') do |title, body|
  visit root_path
  click_link 'New Post'
  fill_in 'Title', with: title
  fill_in 'Content', with: body
  click_button 'Post'
end

When('I visit the post titled {string}') do |title|
  post = Post.find_by!(title: title)
  visit post_path(post)
end

When('I leave a comment {string}') do |comment_body|
  fill_in 'Comment Content', with: comment_body
  click_button 'Submit Comment'
end

Then('I should see {string} in the posts list') do |text|
  within('#posts') do
    expect(page).to have_content(text)
  end
end

Then('I should not see {string} in the posts list') do |text|
  within('#posts') do
    expect(page).not_to have_content(text)
  end
end

Then('I should see {string} on the page') do |text|
  expect(page).to have_content(text)
end

Then('I should see {string} in the comments list') do |text|
  within('#comments') do
    expect(page).to have_content(text)
  end
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('the posts list should not reveal email addresses') do
  within('#posts') do
    expect(page).not_to have_content('@')
  end
end

When('I like the post') do
  click_button('Like (👍 0)')
end

Then('the post like count should be {int}') do |count|
  expect(page).to have_content("👍 #{count}")
end

When('I unlike the post') do
  click_button('Unlike (👍 1)')
end
