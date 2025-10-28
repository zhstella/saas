# CU Blue Board – Verified community. Anonymous voice.

## Team Members (Group 8)
- Chih-Hsin Chen (`cc5240`)
- Seung Jae Hong (`sh4546`)
- Mingliang Yu (`my2899`)
- Yujia Zhai (`yz5133`)

## Project Pitch
- Video: https://youtu.be/9S1olW0Fe4o
- Proposal: see `/docs/proposal.txt`

## Prerequisites
- Ruby `3.2.2` (see `.ruby-version`)
  - Recommended: install via `rbenv` → `brew install rbenv ruby-build`, `rbenv install 3.2.2`, `rbenv local 3.2.2`
- Bundler (`gem install bundler`)
- SQLite 3 (ships with macOS/Linux)

## Local Setup
1. Ensure Bundler is available: `gem install bundler`
2. Install project gems: `bundle install`
3. Prepare the database: `bin/rails db:prepare`
   - Alternatively run `bin/setup` once; it installs gems, prepares the DB, and launches the dev server.

### Running the app
1. Start the server: `bin/dev`
2. Open the browser at http://localhost:3000

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
- 21 examples total across the specs below (all green).
- `spec/models/post_spec.rb`: post validations and keyword search helper.
- `spec/models/comment_spec.rb`: comment presence/association checks.
- `spec/models/like_spec.rb`: uniqueness constraint and helper methods.
- `spec/requests/posts_spec.rb`: create and delete posts with proper authorization + flashes.
- `spec/requests/comments_spec.rb`: delete comments with ownership checks and redirects.

**Cucumber scenarios**
- 5 scenarios / 28 steps covering the primary user journeys.
- `features/posts/browse_posts.feature`: anonymous feed browsing, search filtering, identity masking.
- `features/posts/create_post.feature`: sign-up/login flow and successful post creation.
- `features/comments/add_comment.feature`: authenticated commenting and flash message.
- `features/posts/like_post.feature`: like/unlike toggle with count updates.

## Deployment
- Heroku: _link to be added once the staging app is live_
- Source code: https://github.com/zhstella/CU_Blueboard

## Additional Materials
- Iteration artifacts (such as proposal.txt) are stored in `/docs` as the project evolves.

## Repository Map (key folders)
```text
CU_Blueboard/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # Global Devise auth hook
│   │   ├── posts_controller.rb         # Post CRUD + search
│   │   ├── comments_controller.rb      # Comment create/destroy
│   │   └── likes_controller.rb         # Like toggle endpoints
│   ├── models/
│   │   ├── post.rb                     # Post validations + search helper
│   │   ├── comment.rb                  # Comment validations
│   │   ├── like.rb                     # Like uniqueness + associations
│   │   └── user.rb                     # Devise user with anonymous handle
│   ├── views/posts/                    # Index/show/new templates & shared form partial
│   ├── views/layouts/application.html.erb # Main layout (nav, flashes)
│   ├── helpers/application_helper.rb   # `display_author` pseudonym helper
│   └── javascript/                     # Hotwire/Stimulus entrypoints (default rails)
├── config/
│   ├── routes.rb                       # Devise keyword routes + nested resources
│   ├── environments/{development,test}.rb # Notes integration + Cucumber annotations
│   ├── initializers/devise.rb          # Devise configuration
│   └── initializers/simple_form.rb     # SimpleForm theme overrides
├── db/
│   ├── migrate/                        # Devise users + posts/comments/likes tables
│   └── schema.rb                       # Current SQLite schema
├── docs/
│   └── proposal.txt                    # Iteration proposal document
├── features/
│   ├── comments/add_comment.feature    # Cucumber scenario for commenting
│   ├── posts/browse_posts.feature      # Browse & search flow with anonymity check
│   ├── posts/create_post.feature       # Signup + post creation flow
│   ├── posts/like_post.feature         # Like/unlike toggle flow
│   ├── step_definitions/post_steps.rb  # Shared step implementations
│   └── support/env.rb                  # Cucumber+DatabaseCleaner setup
├── lib/tasks/cucumber.rake             # Rake tasks for Cucumber profiles
├── spec/
│   ├── factories/{users,posts,comments,likes}.rb # FactoryBot fixtures
│   ├── models/{post,comment,like}_spec.rb        # Model specs
│   ├── requests/{posts,comments}_spec.rb         # Authorization specs
│   └── rails_helper.rb                 # RSpec + Devise/Test helpers config
├── test/controllers/*_test.rb          # Stubbed scaffold tests (skipped)
├── README.md                           # Iteration instructions & deliverables
└── Gemfile                             # Dependencies (Rails 8.1, Devise, etc.)
```
