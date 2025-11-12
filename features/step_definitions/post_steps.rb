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
  user = User.create!(email: email, password: password, password_confirmation: password)
  login_as(user, scope: :user)
end

Given('I sign in with email {string} and password {string}') do |email, _password|
  user = User.find_by!(email: email)
  login_as(user, scope: :user)
end

When('I visit the home page') do
  visit '/'
end

When('I search for {string}') do |query|
  visit '/'
  fill_in 'search', with: query
  find('button.search-button').click
end

When('I submit an empty search') do
  visit '/'
  find('button.search-button').click
end

When('I create a post titled {string} with body {string}') do |title, body|
  visit '/'
  click_link 'Submit a Post'
  fill_in 'Title', with: title
  fill_in 'Content', with: body
  click_button 'Post'
end

When('I try to create a post without a title') do
  visit '/'
  click_link 'Submit a Post'
  fill_in 'Title', with: ''
  fill_in 'Content', with: ''
  click_button 'Post'
end

When('I visit the new post page without logging in') do
  logout(:user)
  visit '/posts/new'
end

When('I sign out') do
  logout(:user)
end

When('I visit the post titled {string}') do |title|
  post = Post.find_by!(title: title)
  visit Rails.application.routes.url_helpers.post_path(post)
end

When('I leave a comment {string}') do |comment_body|
  fill_in 'Comment Content', with: comment_body
  click_button 'Submit Comment'
end

When('I submit an empty comment') do
  fill_in 'Comment Content', with: ''
  click_button 'Submit Comment'
end

When('I open the post titled {string}') do |title|
  click_link title
end

When('I reveal my identity on the post titled {string}') do |title|
  post = Post.find_by!(title: title)
  visit Rails.application.routes.url_helpers.post_path(post)
  click_button 'Reveal My Identity'
end

When('I reveal my identity on the most recent comment') do
  within(all('.comment-card').last) do
    click_button 'Reveal My Identity'
  end
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

Then('I should not see {string} in the comments list') do |text|
  within('#comments') do
    expect(page).not_to have_content(text)
  end
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

Then('I should see the thread pseudonym for {string} on {string}') do |email, title|
  user = User.find_by!(email: email)
  post = Post.find_by!(title: title)
  identity = ThreadIdentity.find_by!(user: user, post: post)

  within('#comments') do
    expect(page).to have_content(identity.pseudonym)
  end
end

Then('I should see the alert {string}') do |message|
  expect(page).to have_content(message)
end

Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end
