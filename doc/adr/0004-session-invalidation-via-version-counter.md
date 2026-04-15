# ADR 0004: Session Invalidation via Version Counter

* **Date:** 2026-04-15
* **Status:** Accepted
* **Author:** Greg

---

## 1. Context
By default, Ruby on Rails uses cookie-based encrypted sessions. While highly
scalable and stateless, this approach makes it impossible to invalidate a
user's sessions on other devices (e.g., after a password change) because the
server does not track active sessions.

## 2. Proposed Options
* **Option A:** Database-backed sessions (using `ActiveRecord::SessionStore`).
* **Option B:** Redis-backed sessions.
* **Option C:** Version-based invalidation using a `session_version` column
  on the `User` model.

## 3. Decision
We chose **Option C (Version-based invalidation)**.
> **We introduced a `session_version` integer column to the User model.
This version is embedded in the session payload and compared with the
database value on every request. Incrementing this counter globally
invalidates all existing sessions for that user.**

## 4. Consequences

### ✅ Pros
* **Security:** Allows immediate global logout across all devices upon
  password reset or security breach.
* **Low Infrastructure Cost:** No need for Redis or a dedicated session
  table, keeping the Rails 8 "Solid" (database-backed) philosophy intact.
* **Performance:** The version check is performed during the standard
  current_user fetch, adding negligible overhead.

### ⚠️ Cons
* **Database Hit:** Requires a database lookup for the user record on
  authenticated requests (which Rails usually does anyway).
* **Strictness:** It is an "all or nothing" approach; we cannot invalidate
  a single specific session without affecting others.