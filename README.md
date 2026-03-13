# SmartCart 🛒

An intelligent shopping list application that learns your purchasing habits and suggests what to buy next, powered by Claude AI.

## Features

- **Smart suggestions** — AI analyzes your purchase history and suggests items you're likely running low on
- **Family sharing** — share lists with household members, see real-time updates as items are checked off
- **Multiple lists** — create lists for different occasions, save them as templates
- **Product categories** — organize items by category (dairy, vegetables, bakery, meat, drinks, household, other) with units (pcs, kg, g, l, ml, pack)
- **Purchase history** — browse past purchases, see most frequently bought items
- **Real-time updates** — changes are instantly visible to all household members via Turbo Streams

## Tech Stack

### Backend
- **Ruby on Rails 8** — main framework
- **PostgreSQL** — primary database
- **Devise** — authentication
- **Pundit** — authorization
- **ViewComponent** — UI component architecture
- **Solid Queue** — background job processing (database-backed, no Redis required)
- **Solid Cable** — Action Cable via database (no Redis required)
- **ruby_llm** — Claude API integration (Anthropic)

### Frontend
- **Hotwire** (Turbo Drive + Turbo Frames + Turbo Streams) — SPA-like experience without JavaScript complexity
- **Stimulus** — lightweight JavaScript controllers
- **Vue.js** — interactive islands where Hotwire is insufficient
- **Vite** + **vite-plugin-rails** — asset bundling
- **Tailwind CSS v4** + **DaisyUI** — styling

### Testing
- **RSpec** — test framework
- **FactoryBot** + **Faker** — test data
- **VCR** + **WebMock** — HTTP request recording for AI integration tests

### Infrastructure
- **Docker Compose** — local PostgreSQL
- **GitHub Actions** — CI/CD (security scanning, linting, tests)

## Architecture

### "Less JavaScript" philosophy
This project intentionally minimizes JavaScript. Hotwire handles navigation, form submissions, and real-time updates — no custom JS needed for the majority of features. Vue.js is used only where Hotwire falls short (complex interactive widgets).

### Database-backed infrastructure
No Redis. Rails 8's Solid Queue handles background jobs and Solid Cable handles WebSockets — both use the existing PostgreSQL database. This simplifies both local development and production deployment.

### AI integration
AI suggestions are generated asynchronously via Solid Queue jobs. The job analyzes purchase frequency per product (average days between purchases) and estimates which items are likely running low. User feedback (accept/dismiss/postpone) is stored and factored into future suggestions. VCR cassettes are used in tests to avoid hitting the real API.

### Component architecture
UI components are built with ViewComponent, making them independently testable without rendering full views. Each component has a corresponding RSpec unit test.

### Authorization model
Pundit policies enforce role-based access at the controller level. Households have three roles: `owner` (full access, manage members), `member` (edit lists, check off items), `viewer` (read-only).

## Local Development

```bash
# Start PostgreSQL
docker compose up -d

# Install dependencies
bundle install
npm install

# Setup database
bin/rails db:setup

# Start the server
bin/dev
```

Visit `http://localhost:3000`

## Running Tests

```bash
bundle exec rspec
```


