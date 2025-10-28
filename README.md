# CU Blue Board – Verified community. Anonymous voice.

## Team Members (Group 8)
- Chih-Hsin Chen (`cc5240`)
- Seung Jae Hong (`sh4546`)
- Mingliang Yu (`my2899`)
- Yujia Zhai (`yz5133`)

## Project Pitch
- Video: https://youtu.be/9S1olW0Fe4o
- Proposal: see `proposal.txt`

## Prerequisites
- Ruby `3.2.2` (see `.ruby-version`)
- Bundler (`gem install bundler`)
- SQLite 3 (ships with macOS/Linux)

## Local Setup
```bash
bundle install
bin/rails db:prepare
# or run bin/setup to perform both steps and start the dev server
```

### Running the app
```bash
bin/dev
# visit http://localhost:3000
```

### Default flows covered in Iteration 1
- Browse a feed of posts anonymously, including keyword search without revealing identities
- Register/log in via Devise to get a pseudonymous identity
- Create new questions with title/body validation
- Delete posts you authored with confirmation guardrails
- Reply to a post through comments and remove your own comments
- Toggle likes on posts while preventing duplicate likes per user
- Display pseudonymous handles instead of email addresses on posts and comments

## Test Suites
```bash
# RSpec unit/request coverage
bundle exec rspec

# Cucumber executable user stories
bundle exec cucumber
```

**RSpec coverage**
- `spec/models/post_spec.rb`: post validations and keyword search helper.
- `spec/models/comment_spec.rb`: comment presence/association checks.
- `spec/models/like_spec.rb`: uniqueness constraint and helper methods.
- `spec/requests/posts_spec.rb`: create and delete posts with proper authorization + flashes.
- `spec/requests/comments_spec.rb`: delete comments with ownership checks and redirects.

**Cucumber scenarios**
- `features/posts/browse_posts.feature`: anonymous feed browsing, search filtering, identity masking.
- `features/posts/create_post.feature`: sign-up/login flow and successful post creation.
- `features/comments/add_comment.feature`: authenticated commenting and flash message.
- `features/posts/like_post.feature`: like/unlike toggle with count updates.

## Deployment
- Heroku: _link to be added once the staging app is live_
- Source code: https://github.com/zhstella/CU_Blueboard

## Additional Materials
- Iteration artifacts (such as proposal.txt) are stored in `/docs` as the project evolves.
