# 🛒 SmartCart (Code Name)

**Real-time, location-aware collaborative shopping lists.** SmartCart is a platform designed for groups, roommates, and families, enabling seamless shopping coordination with AI-assisted suggestions and a robust "Mobile-First" approach.

> **Note:** "SmartCart" is currently a code name. The final commercial branding is yet to be determined.

---

## 🚀 Quick Start

### Prerequisites
- Docker Compose


### Setup
1. **Clone the repository:**
   ```bash
   git clone git@github.com:gmalinowski/smart-cart-rb.git
   cd smart-cart-rb
   ```
2. **Start docker containers & enter rails container**
   ```bash
   docker compose up -d
   docker compose exec rails bash
   ```
3. **Setup database**
   ```bash
   bin/rails db:prepare
   bin/rails db:seed
   ```
4. **Launch the app**
   ```bash
   bin/dev
   ```
### 🧪 Testing
We maintain high code quality with RSpec:
```bash
bin/rspec
```
External AI calls are recorded and mocked via **VCR & WebMock**, ensuring fast and deterministic test runs.

## 🏗 Architecture & Tech Stack

The project follows the **Majestic Monolith** philosophy using **Rails 8**.

- **Frontend:** Hotwire (Turbo, Stimulus) + Alpine.js.
- **Backend:** Rails 8, PostgreSQL, Service Objects.
- **Infrastructure:** Solid Queue & Solid Cable (MVP Redis-free model).
- **UI:** ViewComponent - encapsulated UI units in pure Ruby.

### For detailed technical specifications, please refer to our dedicated documentation files:

- 🗺️ [Architecture & Design Decisions (doc/architecture.md)](./doc/architecture.md)
- 🔐 [Authorization Matrix](./doc/authorization-matrix.md)
- 📈 [Database Schema](./doc/assets/db_schema.png)


## 🗺️ Roadmap & Future Vision
Beyond the MVP, the project focuses on location-based intelligence and global scalability:
- **Location Awareness:** Geofencing and proximity alerts to notify group members when someone is near a store.
- **Global Sync:** Transition to **AnyCable + Redis** for low-latency performance across EU and USA regions.
- **AI Analysis:** Receipt processing and automated spending reports.

---

© 2026 Grzegorz Malinowski. Built with passion and Rails 8.