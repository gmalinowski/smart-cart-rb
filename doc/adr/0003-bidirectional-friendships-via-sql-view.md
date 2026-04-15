# ADR 0003: Bidirectional Friendships via SQL View

- **Date:** 2026-03-25
- **Status:** Accepted
- **Author:** Grzegorz Malinowski

---

## 1. Context
Friendships are inherently symmetrical, but relational databases store them
as asymmetrical rows (pair `user_id` and `friend_id`). Querying "all friends"
usually requires complex `OR` conditions or duplicating every row,
which leads to maintenance and performance issues.

## 2. Proposed Options
* **Option A:** Dual-row insertion (creating two rows for every friendship).
* **Option B:** Complex ActiveRecord scopes with `OR` clauses.
* **Option C:** A database-level SQL View (`user_friend_views`) to unify
  the perspective.

## 3. Decision
We chose **Option C (SQL View)**.
> **By using a SQL View, we simplify the application logic, allowing us to
treat friendships as a simple `has_many` association while maintaining high
performance.**

## 4. Consequences

### ✅ Pros
* **Developer Experience:** Allows using standard Rails associations like
  `user.friends`.
* **Performance:** Shifts the heavy lifting of joining and unifying
  relations to the database engine.
* **Consistency:** Eliminates the risk of "half-deleted" friendships often
  found in dual-row setups.

### ⚠️ Cons
* **Read-Only:** The view is read-only; all write operations must target the
  underlying `friendships` table.
* **Schema Management:** Requires managing the view definition within
  migrations.