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
- Google OAuth 2.0 client ID & secret configured for the CU/Barnard domains (see *Configure Google OAuth* below)

## Local Setup
1. Ensure Bundler is available: `gem install bundler`
2. Install project gems: `bundle install`
3. Prepare the database: `bin/rails db:prepare`
   - Alternatively run `bin/setup` once; it installs gems, prepares the DB, and launches the dev server.

### Running the app
1. Start the server: `rails server`
2. Open the browser at http://localhost:3000

### Configure Google OAuth (first-time setup)
1. Create a Google Cloud OAuth client (Web application) and add `http://localhost:3000/users/auth/google_oauth2/callback` as an authorized redirect URI.
2. Store the credentials via Rails encrypted credentials so Devise can read them:
   ```bash
   bin/rails credentials:edit
   ```
   ```yaml
   google_oauth2:
     client_id: YOUR_CLIENT_ID
     client_secret: YOUR_CLIENT_SECRET
   ```
3. Ensure `bundle install` pulled in `omniauth`, `omniauth-google-oauth2`, and `omniauth-rails_csrf_protection`, then run `bin/rails db:migrate` so the `users` table has the new `provider`/`uid` columns.

### Default flows covered in Iteration 1
- Browse a feed of posts anonymously, including keyword search without revealing identities
- Register/log in via Devise to get a pseudonymous identity
- Create new questions with title/body validation
- Delete posts you authored with confirmation guardrails
- Reply to a post through comments and remove your own comments
- Toggle likes on posts while preventing duplicate likes per user
- Display pseudonymous handles instead of email addresses on posts and comments

### Default flows covered in Iteration 2
- Sign in with Columbia/Barnard Google accounts via OmniAuth; the callback controller enforces the domain whitelist and surfaces an “Access Denied” flash for non-campus addresses.
- Reuse existing Devise accounts by linking them to Google on the first SSO attempt (using the new `provider`/`uid` columns) or auto-provision a campus user if no record exists.
- Protect the feed by redirecting signed-out visitors to the redesigned login page via the global `authenticate_user!` hook and the authenticated/unauthenticated root split in `routes.rb`.
- Experience the refreshed login page and global header powered by `application.css` / `login.css` plus the new asset packs, replacing `simple.css` and unifying the UI.

## Test Suites
```bash
# RSpec unit/request coverage
bundle exec rspec

# Cucumber executable user stories
bundle exec cucumber
```

**RSpec coverage**
- Examples cover models, requests, and helpers (all green).
- `spec/models/post_spec.rb`: post validations and keyword search helper.
- `spec/models/comment_spec.rb`: comment presence/association checks.
- `spec/models/like_spec.rb`: uniqueness constraint and helper methods.
- `spec/models/user_spec.rb`: anonymous handle generation and associations.
- `spec/requests/posts_spec.rb`: create and delete posts with proper authorization + flashes.
- `spec/requests/comments_spec.rb`: delete comments with ownership checks and redirects.
- `spec/requests/likes_spec.rb`: like/unlike actions with authentication checks.
- `spec/helpers/application_helper_spec.rb`: display_author pseudonym helper.

**Cucumber scenarios**
- 5 scenarios / 28 steps covering the primary user journeys.
- `features/posts/browse_posts.feature`: anonymous feed browsing, search filtering, identity masking.
- `features/posts/create_post.feature`: sign-up/login flow and successful post creation.
- `features/comments/add_comment.feature`: authenticated commenting and flash message.
- `features/posts/like_post.feature`: like/unlike toggle with count updates.

### Test Coverage

This project uses [SimpleCov](https://github.com/simplecov-ruby/simplecov) to measure test coverage. The coverage approach and configuration were adapted from **COMS W4152 hw-tdd** (Codio 8.9 CHIPS: The Acceptance Test/Unit Test Cycle).

After running both test suites, view the coverage report:

```bash
open coverage/index.html
```

**Target:** 90%+ statement coverage
**Local test results:** 94.23% line coverage, 94.44% branch coverage

Running the test suites will generate a detailed coverage report in `coverage/index.html`.

## Deployment
- Heroku: https://cu-blueboard-27a6a02ee825.herokuapp.com/
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
│   ├── models/{post,comment,like,user}_spec.rb   # Model specs
│   ├── requests/{posts,comments,likes}_spec.rb   # Authorization specs
│   ├── helpers/application_helper_spec.rb        # Helper method specs
│   └── rails_helper.rb                           # RSpec + Devise/Test helpers config
├── simplecov_setup.rb                 # SimpleCov configuration
├── coverage/index.html                # Coverage report (generated by running tests, not in git)
├── test/application_system_test_case.rb # Stub system test base class (no tests)
├── test/system/.keep                   # Placeholder to satisfy Rails system-test task
├── test/test_helper.rb                 # Remaining Minitest harness (empty)
├── README.md                           # Iteration instructions & deliverables
└── Gemfile                             # Dependencies (Rails 8.1, Devise, etc.)
```
