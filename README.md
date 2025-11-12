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
2. Ensure you have the right master key for encrypted credentials. If you need to recreate them locally, remove the existing files and start fresh:
   ```bash
   rm -f config/credentials.yml.enc config/master.key
   ```
   Then open the editor of your choice. Pick one of these commands (remember to include `--wait` for editors that spawn a new window):
   ```bash
   # VS Code
   VISUAL="code --wait" bin/rails credentials:edit

   # nano (built into macOS)
   VISUAL="nano" bin/rails credentials:edit

   # vim
   VISUAL="vim" bin/rails credentials:edit
   ```
   > Tip: if `code` isn’t available in your terminal, launch VS Code and run “Shell Command: Install 'code' command in PATH” from the Command Palette.
   Paste your Google OAuth credentials under the `google_oauth2` key:
   ```yaml
   google_oauth2:
     client_id: YOUR_CLIENT_ID
     client_secret: YOUR_CLIENT_SECRET
   ```
   Save and exit; Rails will regenerate both `config/credentials.yml.enc` and `config/master.key`. Share the new `master.key` securely with your teammates so they can decrypt the credentials.
3. Ensure `bundle install` pulled in `omniauth`, `omniauth-google-oauth2`, and `omniauth-rails_csrf_protection`, then run `bin/rails db:migrate` so the `users` table has the new `provider`/`uid` columns.

### Default flows covered in Iteration 1
- Browse a feed of posts anonymously, including keyword search without revealing identities
- Register/log in via Devise to get a pseudonymous identity
- Create new questions with title/body validation
- Delete posts you authored with confirmation guardrails
- Reply to a post through answers and remove your own answers
- Toggle likes on posts while preventing duplicate likes per user
- Display pseudonymous handles instead of email addresses on posts and answers

### Default flows covered in Iteration 2
- Sign in with Columbia/Barnard Google accounts via OmniAuth; the callback controller enforces the domain whitelist and surfaces an “Access Denied” flash for non-campus addresses.
- Reuse existing Devise accounts by linking them to Google on the first SSO attempt (using the new `provider`/`uid` columns) or auto-provision a campus user if no record exists.
- Protect the feed by redirecting signed-out visitors to the redesigned login page via the global `authenticate_user!` hook and the authenticated/unauthenticated root split in `routes.rb`.
- Experience the refreshed login page and global header powered by `application.css` / `login.css` plus the new asset packs, replacing `simple.css` and unifying the UI.
- Generate thread-specific pseudonyms via the `ThreadIdentity` join table so every author gets a stable alias per conversation instead of a global handle.
- Reveal identities on demand: posts and answers stay anonymous by default, but authors can opt-in to showing their real email with one click, and every reveal is captured in `AuditLog` for moderator traceability.
- Mark posts as ephemeral by selecting a 7/14/30-day expiry window. Expired threads drop off the feed automatically and cannot be opened once the timer elapses.
- Schedule the daily `ExpirePostsJob` (Heroku Scheduler, cron, etc.) to purge threads whose `expires_at` timestamps have passed so the feed stays fresh. Manually trigger it anytime with `rails runner 'ExpirePostsJob.perform_later'`.
- Structure Q&A so every reply is an answer, question authors can accept the best response, and the thread locks (with a reopen button) once solved.

## Test Suites
```bash
# RSpec unit/request coverage
bundle exec rspec

# Cucumber executable user stories
bundle exec cucumber
```

**RSpec coverage**
- 74 examples / 0 failures (line coverage 84.96%, branch coverage 76.32%).
- `spec/models/post_spec.rb`: validations, search helper, and thread-identity callback.
- `spec/models/answer_spec.rb`: validations, per-thread identity creation, and acceptance cleanup.
- `spec/models/like_spec.rb`: uniqueness constraint and helper methods.
- `spec/models/user_spec.rb`: anonymous handle generation and associations.
- `spec/models/thread_identity_spec.rb`, `spec/models/audit_log_spec.rb`: new anonymity infrastructure.
- `spec/requests/posts_spec.rb`: create/delete flows, guest redirects, thread identities, reveal audits.
- `spec/requests/answers_spec.rb`: answer CRUD, validation failures, thread identities, acceptance, and reveal audits.
- `spec/requests/likes_spec.rb`: like/unlike actions with authentication checks.
- `spec/helpers/application_helper_spec.rb`: display_author pseudonym helper.

**Cucumber scenarios**
- Latest run: 18 scenarios / 125 steps passing in ~0.5s via `bundle exec cucumber`.
- Features exercised: answering, browsing/searching, creating posts (including expiring threads), liking/unliking, identity reveals, thread-specific pseudonyms, and locking/unlocking accepted answers to keep threads tidy.
- Coverage snapshot: line 84.96% (226/266), branch 76.32% (58/76). Run with `COVERAGE=true bundle exec cucumber` plus `open coverage/index.html` to inspect details.
- Reports publish to https://reports.cucumber.io by default (`CUCUMBER_PUBLISH_ENABLED=true` in `cucumber.yml`). Set `CUCUMBER_PUBLISH_QUIET=true` locally to silence the banner.
- `features/posts/browse_posts.feature`: authenticated browsing, empty-search alert, and guest redirect to the SSO screen.
- `features/posts/create_post.feature`: signup + creation flow plus validation failures and guest access checks.
- `features/answers/add_answer.feature`: answering success + validation errors.
- `features/posts/like_post.feature`: like/unlike toggle with count updates.
- `features/posts/reveal_identity.feature`: verifies post/answer reveal buttons surface real identities and audit logs.
- `features/posts/thread_pseudonym.feature`: proves each thread shows a unique pseudonym and never leaks the answerer’s email.
- `features/posts/accept_answer.feature`: author accepts an answer, thread locks, and reopening restores the composer.

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
- A daily `ExpirePostsJob` can be scheduled (e.g., via Heroku Scheduler or cron) to purge posts whose `expires_at` timestamp has passed.

## Addressing Iteration 1 Feedback
- Added Cucumber coverage for empty-search alerts, validation errors, and guest redirects so the user stories graders requested are now executable specs (`features/posts/browse_posts.feature`, `features/posts/create_post.feature`, `features/answers/add_answer.feature`).
- Locked down the post form behind authentication and documented the behavior so unauthenticated users see the SSO screen before posting (`config/routes.rb:22-33`, `features/posts/create_post.feature`).
- Ensured post/answer deletion buttons continue to use confirmation prompts via Turbo `data-turbo_confirm`, matching the “confirmation guardrails” mentioned in the README (`app/views/posts/show.html.erb:61-70`).

## Repository Map (key folders)
```text
CU_Blueboard/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # Global Devise auth hook
│   │   ├── posts_controller.rb         # Post CRUD + search
│   │   ├── answers_controller.rb       # Answer create/destroy/accept
│   │   └── likes_controller.rb         # Like toggle endpoints
│   ├── models/
│   │   ├── post.rb                     # Post validations + search helper
│   │   ├── answer.rb                   # Answer validations + reveal support
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
│   ├── migrate/                        # Devise users + posts/answers/likes tables
│   └── schema.rb                       # Current SQLite schema
├── docs/
│   └── proposal.txt                    # Iteration proposal document
├── features/
│   ├── answers/add_answer.feature      # Cucumber scenario for answering
│   ├── posts/browse_posts.feature      # Browse & search flow with anonymity check
│   ├── posts/create_post.feature       # Signup + post creation flow
│   ├── posts/like_post.feature         # Like/unlike toggle flow
│   ├── step_definitions/post_steps.rb  # Shared step implementations
│   └── support/env.rb                  # Cucumber+DatabaseCleaner setup
├── lib/tasks/cucumber.rake             # Rake tasks for Cucumber profiles
├── spec/
│   ├── factories/{users,posts,answers,likes}.rb # FactoryBot fixtures
│   ├── models/{post,answer,like,user}_spec.rb   # Model specs
│   ├── requests/{posts,answers,likes}_spec.rb   # Authorization specs
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
