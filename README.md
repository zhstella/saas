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

## Local Setup (clone → run app)
1. **Clone the repo** and `cd` into it.
2. Install tooling:
   ```bash
   gem install bundler
   bundle install
   ```

3. Configure Google OAuth the first time you work on this repo:
   1. Create a Web client in Google Cloud Console and add both `http://localhost:3000/users/auth/google_oauth2/callback` and `http://127.0.0.1:3000/users/auth/google_oauth2/callback` under *Authorized redirect URIs*. (Leave “Authorized JavaScript origins” empty.)
   2. Remove the old encrypted credentials and add the new secrets:
      ```bash
      rm -f config/credentials.yml.enc
      bin/rails credentials:edit
      ```
      If you prefer a specific editor, prefix with `VISUAL="code --wait"`, `VISUAL="nano"`, `VISUAL="vim"` etc. For example, you can run `VISUAL="vim" bin/rails credentials:edit`.
      Paste the block below so Rails rewrites `config/credentials.yml.enc` and `config/master.key`:
      ```yaml
      google_oauth2:
        client_id: YOUR_CLIENT_ID
        client_secret: YOUR_CLIENT_SECRET
      ```
      Save/exit and share the regenerated `config/master.key` securely with your team. Confirm the entry with `bin/rails credentials:show`.
4. Prepare the database:
   ```bash
   bin/rails db:prepare
   bin/rails db:seed   # seeds topics/tags for the composer/search filters
   ```
5. Run migrations (after installing the OmniAuth gems via `bundle install`, which our Gemfile already lists):
   ```bash
   bin/rails db:migrate
   ```
6. Start the app:
   ```bash
   bin/rails server
   ```
   Then visit http://localhost:3000 or http://127.0.0.1:3000.

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
- Structure Q&A so every reply is an answer, question authors can accept the best response, and the thread locks (with a reopen button) once solved.
- Author posts with the taxonomy-driven composer: pick an official topic, add 1-5 curated tags, capture school/course context, and open an inline draft preview before publishing.
- Filter the feed with full-text search plus topic, tag, school, course, timeframe, and status facets powered by the new `PostSearchQuery` service.

## Test Suites
```bash
# RSpec unit/request coverage
bundle exec rspec

# Cucumber executable user stories
bundle exec cucumber
```

**RSpec coverage**
- 89 examples / 0 failures (line coverage 93.97%, branch coverage 81.63%).
- `spec/models/post_spec.rb`: validations, taxonomy limits, search helper, and thread-identity callback.
- `spec/models/answer_spec.rb`: validations, per-thread identity creation, and acceptance cleanup.
- `spec/models/like_spec.rb`: uniqueness constraint and helper methods.
- `spec/models/user_spec.rb`: anonymous handle generation, OmniAuth linkage, and associations.
- `spec/models/thread_identity_spec.rb`, `spec/models/audit_log_spec.rb`: new anonymity infrastructure.
- `spec/requests/posts_spec.rb`: create/delete flows, guest redirects, thread identities, reveal audits, and taxonomy validations.
- `spec/requests/answers_spec.rb`: answer CRUD, validation failures, thread identities, acceptance, and reveal audits.
- `spec/requests/likes_spec.rb`: like/unlike actions with authentication checks.
- `spec/requests/omniauth_callbacks_spec.rb`: Google SSO domain enforcement and account linking.
- `spec/helpers/application_helper_spec.rb`: display_author pseudonym helper.
- `spec/queries/post_search_query_spec.rb`: filter coverage for the topic/tag/timeframe search service.

**Cucumber scenarios**
- Latest run: 19 scenarios / 129 steps passing in ~0.7s via `bundle exec cucumber`.
- Features exercised: answering, browsing/searching, creating posts (including expiring threads and previewing drafts), liking/unliking, identity reveals, thread-specific pseudonyms, and locking/unlocking accepted answers to keep threads tidy.
- Coverage snapshot: line 95.62% (349/365), branch 83.67% (82/98). Run with `COVERAGE=true bundle exec cucumber` plus `open coverage/index.html` to inspect details.
- Reports publish to https://reports.cucumber.io by default (`CUCUMBER_PUBLISH_ENABLED=true` in `cucumber.yml`). Set `CUCUMBER_PUBLISH_QUIET=true` locally to silence the banner.
- `features/posts/browse_posts.feature`: authenticated browsing, the advanced filter bar (search + facets), empty-search alerts, and guest redirect to the SSO screen.
- `features/posts/create_post.feature`: signup + creation flow, validation failures, expiring threads, and draft preview UX.
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
**Local test results:** 95.62% line coverage, 83.67% branch coverage

Running the test suites will generate a detailed coverage report in `coverage/index.html`.

## Deployment
- Heroku: https://cu-blueboard-27a6a02ee825.herokuapp.com/
- Source code: https://github.com/zhstella/CU_Blueboard

## Additional Materials
- Iteration artifacts (such as proposal.txt) are stored in `/docs` as the project evolves.
- A daily `ExpirePostsJob` can be scheduled (e.g., via Heroku Scheduler or cron) to purge posts whose `expires_at` timestamp has passed.
- Seeded tag allowlist (via `TaxonomySeeder`): `academics`, `courses/coms`, `advising`, `housing`, `visas-immigration`, `financial-aid`, `mental-health`, `student-life`, `career`, `marketplace`, `accessibility-ods`, `public-safety`, `tech-support`, `international`, `resources`.

## Addressing Iteration 1 Feedback
- Added the missing user-story coverage that graders flagged (blank search alert, invalid post/answer validations, and guest redirects) so every scenario now runs via Cucumber (`features/posts/browse_posts.feature`, `features/posts/create_post.feature`, `features/answers/add_answer.feature`).
- Kept the post creation flow behind authentication and clarified the behavior in both README and acceptance tests so unauthenticated users always see the SSO screen first (`config/routes.rb`, `features/posts/create_post.feature`).
- Verified that delete buttons still show a Turbo confirmation prompt before removing posts/answers, matching the “confirmation guardrails” promise in the README (`app/views/posts/show.html.erb`).
- Trimmed optional directories (e.g., removed unused `app/mailers/`) so coverage reporting aligns with the actual code we ship and reflects the >95% combined line coverage.

## Repository Map (key folders)
```text
CU_Blueboard/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb   # Global Devise auth hook
│   │   ├── posts_controller.rb         # Post CRUD + search
│   │   ├── answers_controller.rb       # Answer create/destroy/accept
│   │   └── likes_controller.rb         # Like toggle endpoints
│   ├── queries/
│   │   └── post_search_query.rb        # Multi-filter feed search service
│   ├── services/
│   │   └── taxonomy_seeder.rb          # Seeds topics & tags (TaxonomySeeder)
│   ├── models/
│   │   ├── post.rb                     # Post validations + taxonomy + status helpers
│   │   ├── answer.rb                   # Answer validations + reveal support
│   │   ├── like.rb                     # Like uniqueness + associations
│   │   ├── tag.rb / topic.rb / post_tag.rb # Taxonomy models
│   │   └── user.rb                     # Devise user with anonymous handle + OmniAuth
│   ├── views/posts/                    # Index/show/new templates & shared form partial
│   ├── views/layouts/application.html.erb # Main layout (nav, flashes)
│   ├── helpers/application_helper.rb   # `display_author` pseudonym helper
│   └── javascript/
│       ├── controllers/post_show_controller.js # Toggles answer form
│       └── controllers/tag_picker_controller.js # Enforces tag selection limits
├── config/
│   ├── routes.rb                       # Devise keyword routes + nested resources
│   ├── environments/{development,test}.rb # Notes integration + Cucumber annotations
│   ├── initializers/devise.rb          # Devise configuration
│   └── initializers/simple_form.rb     # SimpleForm theme overrides
├── db/
│   ├── migrate/                        # Devise + posts/answers/likes/topics/tags tables
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
│   ├── requests/{posts,answers,likes,omniauth_callbacks}_spec.rb # Auth specs
│   ├── helpers/application_helper_spec.rb        # Helper method specs
│   ├── queries/post_search_query_spec.rb         # Search service specs
│   └── rails_helper.rb                           # RSpec + Devise/Test helpers config
├── simplecov_setup.rb                 # SimpleCov configuration
├── coverage/index.html                # Coverage report (generated by running tests, not in git)
├── test/application_system_test_case.rb # Stub system test base class (no tests)
├── test/system/.keep                   # Placeholder to satisfy Rails system-test task
├── test/test_helper.rb                 # Remaining Minitest harness (empty)
├── README.md                           # Iteration instructions & deliverables
└── Gemfile                             # Dependencies (Rails 8.1, Devise, etc.)
```
