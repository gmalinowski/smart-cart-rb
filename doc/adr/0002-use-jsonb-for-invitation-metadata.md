# ADR 0002: Use JSONB for Invitation Metadata

- **Date:** 2026-03-24
- **Status:** Accepted
- **Author:** Grzegorz Malinowski

---

## 1. Context
The `InvitationLink` model currently requires storing only a `recipient_email`
to handle invitations for users who do not yet have an account. While a simple
`VARCHAR` column would be sufficient for this single requirement, we anticipate
future needs for diverse invitation types (e.g., promotional codes, referral
tokens, or group-specific data). These additions would lead to a sparse table
with numerous nullable columns or frequent, disruptive schema migrations.

## 2. Proposed Options
* **Option A:** Add specific columns (e.g., `recipient_email`) as needed.
* **Option B:** Implement a polymorphic association to separate metadata tables
  (e.g., `EmailInvitationData`, `PromoInvitationData`).
* **Option C:** Use a single `jsonb` column named `metadata` within the
  `invitation_links` table.

## 3. Decision
We chose **Option C (JSONB)**.
> **While Option A is more "correct" for the current state, we opted for
JSONB to provide immediate architectural flexibility. This allows us to
experiment with new invitation features without the overhead of managing
complex polymorphic structures or constant migrations.**

## 4. Consequences

### ✅ Pros
* **Flexibility:** We can add or remove invitation attributes on the fly as the
  social module evolves.
* **Simplicity:** Keeps the database schema lean by avoiding multiple
  one-to-one tables or a "Swiss cheese" table of nulls.
* **Performance:** PostgreSQL's JSONB format is binary and indexable, ensuring
  that performance remains high even as metadata grows.

### ⚠️ Cons
* **Schema-less Risks:** The database does not enforce a structure, shifting
  the responsibility for data integrity entirely to ActiveRecord validations.
* **Overengineering:** We are using a sophisticated tool for a simple task,
  which adds a slight layer of complexity to the initial implementation.