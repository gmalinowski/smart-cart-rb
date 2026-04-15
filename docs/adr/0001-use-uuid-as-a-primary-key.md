# ADR 0001: Use UUID as Primary Key

- **Date:** 2026-03-15
- **Status:** Accepted
- **Author:** Grzegorz Malinowski

---

## 1. Context
Standard Rails applications use auto-incrementing integers as PK. While efficient, this exposes system size via predictable resource and can cause collisions in distributed systems or during database merges.

## 2. Considered Options
- **Option A:** BigInt
- **Option B:** UUID

## 3. Decision Outcome
We chose **Option B (UUID)**.

> **We selected UUIDs to enhance security by preventing ID enumeration and to ensure global uniqueness across different environments.**

## 4. Consequences
### ✅ Pros
* **Security:** Prevents malicious users from guessing record IDs or estimating the total number of records.
* **Scalability:** Simplifies data migration and merging records from multiple databases without ID conflicts.
* **Decoupling:** IDs can be generated before the record hits the database.

### ⚠️ Cons
* **Storage:** UUIDs consume more space (128-bit) compared to Integers (64-bit).
* **Performance:** Indexing might be slightly slower, although mitigated by PostgreSQL's native `uuid` type support.