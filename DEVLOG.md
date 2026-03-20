# Devlog
> Grzegorz Malinowski <git.15m27@passmail.net>

## Project description

### What real-life problem does the app solve?

The app makes everyday shopping more convenient, especially for people
living together or in close-knit groups.

A user can add items to a shared grocery list, and others can pick them
up whenever they happen to be nearby.

### Requirements
- Shopping lists can be shared with groups, selected users, or publicly via a link.
- List changes are visible in real-time, allowing multiple users to shop from the same list simultaneously.
- List items have a configurable priority (scale 1–3).
- List creation is AI-assisted — the AI analyzes purchase history and suggests items.
- Authentication supports email/password and OAuth (Google).
- Mobile-first design.

#### Future ideas
- Store shopping receipts in the database — AI could analyze them and generate spending reports.
- If the MVP proves promising, a JSON API for a mobile app could be added.

### Techstack
Its just blueprint, the stack can change along the way.

#### Backend
- Ruby on Rails 8 — main framework
- PostgreSQL — primary database
- Devise — authentication
- Pundit — authorization
- ViewComponent — UI component architecture
  Arguably the current standard for building UI in Rails. The component-based approach
  offers more flexibility, better reusability, stronger isolation which reduces bugs,
  and components are much easier to test.
- Solid Queue — background job processing (database-backed, no Redis required)
  Default in Rails 8. Reduces infrastructure complexity by eliminating the need for
  Redis. Performance-wise there is no significant difference for this use case.
- Solid Cable — Action Cable via database (no Redis required)
  Default in Rails 8. Eliminates the need for Redis, performance is good enough for
  this project. In the future, AnyCable would be a more performant option, but that
  would be overkill at this stage.
- ruby_llm — Claude API integration (Anthropic)
  A simple but mature gem supporting 800+ AI models with solid Rails integration.
  Handles the project's AI requirements without unnecessary complexity.

#### Frontend
- Hotwire (Turbo Drive + Turbo Frames + Turbo Streams) — SPA-like experience without JavaScript complexity
  Hotwire enables real-time communication with minimal complexity.
- Stimulus — lightweight JavaScript controllers
  Provides a simple bridge between Rails and Vue.js components.
- Vue.js — interactive islands where Hotwire is insufficient
  In terms of philosophy and ergonomics, Vue.js fits this setup better than React,
  while still providing access to a large and mature ecosystem — unlike Svelte, which
  would be technically optimal but carries risk due to its smaller community and library availability.
- Vite + vite-plugin-rails — asset bundling
  The project consists of a relatively large amount of JavaScript, making Vite the natural
  choice — it allows full utilization of the JS/npm ecosystem.
- Tailwind CSS v4 + DaisyUI — styling
  Tailwind is the de facto standard in modern web development. It strikes a great balance
  between productivity and flexibility. UI kits like DaisyUI extend this further with
  ready-made components.

#### Testing
- RSpec — test framework
- FactoryBot + Faker — test data
- VCR + WebMock — HTTP request recording for AI integration tests

#### Infrastructure
- Ubuntu (dev + server)
- Docker Compose — local PostgreSQL
- GitHub Actions — CI/CD (security scanning, linting, tests)
- Kamal - deploy

#### Utils
- RubyMine (JetBrains)

## 2026-03-13 Project Setup
- Vite + remove importmap
- tailwind
- daisyui
- TypeScript
- github CI
- secure main branch, allows only merging by PR
- docker compose dla Postgresql
- RSpec, FactoryBot, Faker, VCR, WebMock


## 2026-03-14
Designing — created basic wireframes for the app.

Starting with wireframes is the best way to think about the app at a high level.
This approach makes it safer to move from global problems to more specific ones.
Specific problems can usually be solved along the way, but mistakes made at the
global level often require redesigning the entire project.

Wireframes: [link](https://app.moqups.com/aOzyxSGZpRLksQLUObjLiNRienMWPO0M/view/page/a7bc758b4)

## 2026-03-15
Scratch database schema.
Here is the diagram: [link](https://dbdiagram.io/d/69b6d813fb2db18e3b83b356)

## 2026-03-16
Basic auth functionality using Devise — signup, signin, password reset, email confirmation. Added basic styling for all auth pages.

**session_version** — by default, Rails provides no way to invalidate user sessions on other devices. This is because sessions are stored in encrypted cookies, signed with the Rails master key, and the server holds no session state.

The simplest solution, without migrating sessions to the database, was introducing a session_version counter on the User model. Each time a user changes their password, the counter increments. Any existing sessions stored in the browser carry the old version and are immediately rejected on the next request.

## 2026-03-17
2026-03-17
Homepage with shopping list creation flow.

Added homepage with a single input form — user types a product name and hits "Add". This creates a new shopping list (named with today's date) with the first item, then redirects to the list edit page. List creation logic is encapsulated in a CreateShoppingListWithItem service object.

Database schema changes: Added shopping_lists and shopping_list_items tables with UUID primary keys. Items have cascade delete on shopping list removal. Dropped status column from shopping_lists in favor of dynamic state checking (draft = no groups and no public link).

## 2026-03-18

Added bottom dock navigation with responsive behavior — the dock adapts to the on-screen keyboard using `interactive-widget=resizes-content`. On short screens the dock switches to a compact mode via a custom Tailwind variant (`@custom-variant screen-short`).

Restricted `shopping_lists` routes to only the required actions (`show`, `destroy`). Moved list creation logic from `ListItemsController` into `ShoppingListsController`, cleaning up the separation of responsibilities between controllers.

Added a shopping lists index view with items grouped by category.

## 2026-03-19
Added real-time item management to shopping list view — items append instantly via Turbo Streams broadcast (`after_create_commit`, `after_destroy_commit`) keeping all collaborators in sync without page reload. Form resets after submission via `create.turbo_stream.erb`. Fixed layout issue where dock was obscuring list items by removing fixed height from `<main>` and relying on native browser scroll with bottom padding instead.



