# SmartCart (internal codename) 🛒

<<<<<<< Updated upstream
> ### For a more detailed look at the development process and decisions, see [DEVLOG.md](DEVLOG.md).
> ### Documentation: [docs](docs)
 
A collaborative shopping list app where you can share lists with groups, selected friends, or publicly via a link — with real-time updates so multiple people can shop from the same list simultaneously.
 
## Features
 
- **Groups** — create a group (family, flatmates, friends), share lists with all members at once
- **Friend-based sharing** — share individual lists with selected friends outside your groups
- **Public link sharing** — share a list publicly via a link, with configurable view or edit permissions
- **Real-time updates** — changes are instantly visible to all collaborators via Turbo Streams
- **Item priorities** — mark items as must-have, regular, or optional (scale 1–3)
- **Product categories** — organize items by category (dairy, vegetables, bakery, meat, drinks, household, other) with units (pcs, kg, g, l, ml, pack)
- **Saved lists** — save any list as a template for later reuse
- **Visit history** — quickly access recently viewed lists
- **Purchase history** — browse past purchases, see most frequently bought items
- **AI-assisted list creation** — AI analyzes purchase history and suggests items when creating a new list
 
## Future Ideas
 
- Receipt scanning — upload a photo of a receipt, AI analyzes it and generates spending reports
- Mobile app — JSON API for a native mobile client if the MVP proves promising
 
## Tech Stack
 
### Backend
- **Ruby on Rails 8** — main framework
- **PostgreSQL** — primary database
- **Devise** — authentication (email/password + OAuth)
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
- **Kamal** — deployment
 
## Architecture
 
### "Less JavaScript" philosophy
This project intentionally minimizes JavaScript. Hotwire handles navigation, form submissions, and real-time updates — no custom JS needed for the majority of features. Vue.js is used only where Hotwire falls short (complex interactive widgets).
 
### Database-backed infrastructure
No Redis. Rails 8's Solid Queue handles background jobs and Solid Cable handles WebSockets — both use the existing PostgreSQL database. This simplifies both local development and production deployment.
 
### Sharing model
Lists can be shared in three ways: with a group (all members get access), with selected friends (requires an accepted friendship), or publicly via a generated link (view or edit permission). A list can have only one owner but multiple sharing contexts simultaneously.
 
### AI integration
AI suggestions are generated asynchronously via Solid Queue jobs. The job analyzes purchase frequency per product and estimates which items are likely running low. User feedback (accept/dismiss/postpone) is stored and factored into future suggestions. VCR cassettes are used in tests to avoid hitting the real API.
 
### Component architecture
UI components are built with ViewComponent, making them independently testable without rendering full views. Each component has a corresponding RSpec unit test.
 
### Authorization model
Pundit policies enforce role-based access at the controller level. Groups have two roles: `owner` (full access, manage members) and `member` (edit lists, check off items). List-level permissions are managed separately through the sharing model.
 
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
 
=======
A collaborative, real-time shopping assistant built with **Ruby on Rails 8**. Share lists with groups, friends, or via public links with instant updates for all collaborators.

## 🏛️ Architecture & Decisions

This project follows a **"Documentation as Code"** approach. For deep dives into the system design and specific technical choices, please refer to:

* [**System Architecture Overview**](./docs/architecture.md) – A high-level view of modules, data flow, and the sharing model.
* [**Architecture Decision Records (ADR)**](./doc/adr/) – Detailed justifications for key technical choices (e.g., UUIDs, Solid Stack).
* [**Development Guide**](./docs/development.md) – Detailed setup and contribution instructions.

## 🚀 Key Technical Challenges & Solutions

### 🔐 Global Session Invalidation
Implemented a `session_version` mechanism on the `User` model to allow instant logout across all devices without the overhead of database-backed sessions. Any change in security credentials increments the version, invalidating existing browser cookies.

### ⚡ Real-time UX without the "Scroll Jump"
Solved common Turbo Stream UI issues, such as unwanted browser scrolling when elements are replaced. Implemented a Stimulus-based focus management system that ensures a seamless experience during rapid list updates.

### 🧠 Async AI Suggestions
Built an asynchronous pipeline using **Solid Queue** to analyze purchase patterns via **Claude AI (Anthropic)**. This ensures that heavy AI computations never block the main web thread.

## 🛠️ Tech Stack

### Backend
- **Ruby on Rails 8** (Solid Queue, Solid Cable, ViewComponent)
- **PostgreSQL** & **Pundit** (AuthZ)
- **ruby_llm** (Anthropic Claude integration)

### Frontend
- **Hotwire** (Turbo & Stimulus) & **Alpine.js**
- **Vite** & **Tailwind CSS v4** (DaisyUI)
>>>>>>> Stashed changes
