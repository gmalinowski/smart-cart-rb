# Project Vision: SmartCart — The Pulse of the Modern Household

## 1. The Core Philosophy: A Living Shopping List
SmartCart is fundamentally a **Real-time Collaborative Shopping List** designed
to diminish the "mental load" of domestic life. In every shared household,
there is an invisible tax of coordination: "Who bought the milk?", "Do we
have eggs?", "I'm at the store, does anyone need anything?".

SmartCart turns a fragmented, stressful chore into a seamless, **instantaneous
flow of information**. It is not a static notebook; it is a shared
consciousness for the household.

---

## 2. Key Pillar: Foundation of Real-time
The absolute bedrock of SmartCart is **instantaneous synchronization**.
A shopping list is only as good as its latest update.
* **Zero-Latency Updates:** Using Turbo Streams and WebSockets, every
  checkmark, added item, or note is broadcasted to all collaborators
  in milliseconds.
* **No Manual Refreshes:** The app feels like a single, physical sheet
  of paper held by multiple people at once.
* **State Consistency:** Whether you are in the store or at home, you
  are always looking at the exact same version of the truth.

---

## 3. Design & Blueprint (The "Definition" Phase)
Before any code was written, the project underwent a rigorous design
process to ensure that the technical architecture serves the user's needs.

* **Conceptual Wireframes:** [Interactive Prototypes (Moqups)](https://app.moqups.com/aOzyxSGZpRLksQLUObjLiNRienMWPO0M/view/page/a7bc758b4)
* **Data Schema Blueprint:** [Initial ERD Design (dbdiagram.io)](https://dbdiagram.io/d/69b6d813fb2db18e3b83b356)

---

## 4. The "Opportunistic Shopping" Framework
SmartCart shifts the paradigm from "planned trips" to **"opportunistic
purchasing"** through three core interaction patterns:

1. **The Quick Glance:** A mobile-first UI for the "already in store"
   scenario. Instantly see what others added just seconds ago.
2. **The Active Broadcast:** A "One-Tap" notification system.
   *"I'm at [Store X], what do we need?"*. This alerts all list
   members with a real-time notification and location link.
3. **The Proximity Sentinel:** Subscribe to specific stores. If a
   member enters a tagged location, the system automatically nudges
   them: *"You're near the Pet Store, the household needs Cat Food."*

---

## 5. Solving the "Coordination Tax"
We address the fundamental failures of modern shopping:
* **The Information Gap:** Not knowing what is needed until it's too late.
* **The Double-Purchase Trap:** Two people buying the same perishables.
* **The Cognitive Burden:** Having to remember routine purchases manually.

---

## 6. Strategic Roadmap

### Phase 1: The Reactive Core (Active)
Establishing the real-time foundation, UUID security, and the custom
"Flash Bridge" notification system.

### Phase 2: Location & Broadcast (Q4 2026)
Implementation of the "Opportunistic Shopping" framework: Geofencing,
active store broadcasts, and location-aware reminders.

### Phase 3: Professional Expansion (B2B)
Adapting the "Living List" for professional kitchens and restaurants,
where rapid sync between chefs and purchasers is critical.

### Phase 4: The Analytical Brain (2027)
LLM-based inventory prediction (`ruby_llm`) and OCR receipt processing
for automated household spending insights.

---

## 7. Engineering as an Art Form
We embrace the "Majestic Monolith" with Rails 8. By utilizing **Solid Cable** and **Solid Queue**, we maintain a zero-Redis infrastructure while
providing enterprise-grade real-time capabilities. Every technical
decision is documented via ADRs to ensure long-term maintainability.
