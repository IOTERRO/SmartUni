# Cloudflare Locations DB — Architecture alignment

This document describes your **real** D1 navigation database and how it fits the SmartUni Flutter architecture.

| Item | Value |
|------|--------|
| D1 database name | `cityu` |
| Main table (exists) | `locations` |
| Worker | `navigation` |
| Worker URL (app config) | `https://navigation.khaledothman750.workers.dev` |
| Worker binding | D1 `DB` → `cityu` · Secret `API_KEY` |
| Worker source code | [`Backend/worker/navigation-worker.js`](../Backend/worker/navigation-worker.js) |
| Deploy guide | [`Backend/worker/NAVIGATION_README.md`](../Backend/worker/NAVIGATION_README.md) |
| Flutter feature | Navigation (Guest + Student + Admin module) |
| Flutter repository (later) | `NavigationRepository` → replace `MockNavigationRepository` |
| Flutter model (later mapping) | `CampusLocation` |

Related docs:

- Architecture: [`03_CODE_AND_ARCHITECTURE_DETAILED.md`](./03_CODE_AND_ARCHITECTURE_DETAILED.md)
- Attendance DB: [`04_CLOUDFLARE_ATTENDANCE_DB.md`](./04_CLOUDFLARE_ATTENDANCE_DB.md)
- SQL helpers: [`sql/locations_d1_schema.sql`](./sql/locations_d1_schema.sql)

---

## 1. Where this sits in the architecture

```text
┌──────────────────────────────┐
│ Flutter UI                   │
│ NavigationScreen             │
│ AdminNavigationScreen        │
└──────────────┬───────────────┘
               │ Step 2: HTTP
               ▼
┌──────────────────────────────┐
│ Cloudflare Worker            │
│ smart-university...workers   │
└──────────────┬───────────────┘
               │ D1 binding (DB)
               ▼
┌──────────────────────────────┐
│ D1 database: cityu           │
│  ├── locations        ✅ now │
│  └── location_edges   ⬜ next│
└──────────────────────────────┘
```

**Roles that use this data**

| Role | Access |
|------|--------|
| Guest | Read locations / routes (public) |
| Student | Read locations / routes |
| Admin | Read + later Add / Update / Delete locations |

**Not stored here:** users, attendance, parking (parking = Firebase).

---

## 2. Current table: `locations` (what you already have)

From your Cloudflare Studio (`cityu` → `locations`):

| Column | Type | Role | Example |
|--------|------|------|---------|
| `id` | INTEGER PK | Unique row id | `1` |
| `code` | TEXT | Short campus code | `ADMIN`, `LIB`, `KABA` |
| `name` | TEXT | Display name in app | `Central Library` |
| `description` | TEXT | Detail text | `University central library` |
| `latitude` | REAL / NULL | Map / GPS | `34.41845` |
| `longitude` | REAL / NULL | Map / GPS | `35.83539` |

### Current rows (your data)

| id | code | name | description | lat | lng |
|----|------|------|-------------|-----|-----|
| 1 | CITYU | City University Campus | Main campus in Abu Samra, Tripoli | 34.41845 | 35.83539 |
| 2 | ADMIN | Administration | University administration building | NULL | NULL |
| 3 | LIB | Central Library | University central library | NULL | NULL |
| 4 | KABA | KABA | KABA building | NULL | NULL |
| 5 | SHOUMAN | Shouman Building | Shouman building | NULL | NULL |

### Verdict

**Good base schema** for campus places / directory / map pins.  
Keep it. Improve data + add edges for routing (sections 3–4).

---

## 3. Recommended improvements (keep compatible)

Run in D1 Console on `cityu` (safe `ALTER`s):

```sql
-- Optional but recommended columns
ALTER TABLE locations ADD COLUMN type TEXT;           -- campus | building | library | admin
ALTER TABLE locations ADD COLUMN floor INTEGER DEFAULT 0;
ALTER TABLE locations ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
```

Suggested `type` values for your rows:

| code | type |
|------|------|
| CITYU | campus |
| ADMIN | admin |
| LIB | library |
| KABA | building |
| SHOUMAN | building |

**Must do for map/navigation quality:** fill `latitude` / `longitude` for **every** building (not only CITYU).

---

## 4. Second table for routing: `location_edges`

`locations` lists places.  
**Route finding** needs links between places (graph).

```sql
CREATE TABLE IF NOT EXISTS location_edges (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  from_location_id   INTEGER NOT NULL,
  to_location_id     INTEGER NOT NULL,
  distance_meters    REAL NOT NULL,
  path_type          TEXT DEFAULT 'walk',  -- walk | road | indoor
  is_bidirectional   INTEGER NOT NULL DEFAULT 1, -- 1 = also reverse
  created_at         TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (from_location_id, to_location_id),
  FOREIGN KEY (from_location_id) REFERENCES locations(id),
  FOREIGN KEY (to_location_id) REFERENCES locations(id)
);

CREATE INDEX IF NOT EXISTS idx_edges_from ON location_edges(from_location_id);
CREATE INDEX IF NOT EXISTS idx_edges_to ON location_edges(to_location_id);
```

### Example edges (adjust distances later with real campus measures)

```sql
INSERT INTO location_edges (from_location_id, to_location_id, distance_meters) VALUES
  (1, 2, 90),    -- CITYU campus ↔ Administration
  (1, 3, 140),   -- CITYU campus ↔ Library
  (1, 4, 160),   -- CITYU campus ↔ KABA
  (1, 5, 180),   -- CITYU campus ↔ Shouman
  (2, 3, 70),    -- Admin ↔ Library
  (3, 4, 110),   -- Library ↔ KABA
  (4, 5, 95);    -- KABA ↔ Shouman
```

Worker route algorithm (later): shortest path on this graph (e.g. Dijkstra) using `distance_meters`.

---

## 5. Mapping Cloudflare → Flutter architecture

### D1 row → Flutter model

Today Step 1 uses mock `CampusLocation`. When wiring Step 2, map like this:

| D1 `locations` | Flutter `CampusLocation` |
|----------------|--------------------------|
| `id` (int) → `toString()` | `id` (String) |
| `name` | `name` |
| `type` (or derive from `code`) | `type` |
| `floor` (default 0) | `floor` |
| `code` | `building` (or keep as code) |
| `description` | `description` |
| `latitude` / `longitude` | extend model later for map |

### Repository contract (already in app)

```text
NavigationRepository
  ├── fetchLocations()     → SELECT * FROM locations WHERE is_active = 1
  ├── search(query)        → WHERE name/code/description LIKE ?
  └── findRoute(from, to)  → use location_edges + path algorithm
```

Step 1: `MockNavigationRepository`  
Step 2: `CloudflareNavigationRepository` calling the Worker

### Config already prepared

`AppConfig.navigationWorkerUrl`  
Secrets: `Secrets.navigationWorkerApiKey` (from `secrets.example.dart` → local `secrets.dart`)

---

## 6. Worker API shape (implemented)

Worker code lives in `Backend/worker/smart-university-worker.js`.  
Paste it into Cloudflare **Edit code** → Save and Deploy (see `Backend/worker/README.md`).

Keep these endpoints aligned with the Flutter repository:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/locations` | List all active locations |
| GET | `/api/locations/search?q=` | Search |
| GET | `/api/navigation?from=&to=` | Route (`from`/`to` = location `id` or `code`) |
| POST | `/api/locations` | Admin add (later) |
| PUT | `/api/locations/:id` | Admin update (later) |
| DELETE | `/api/locations/:id` | Admin delete (later) |

### Example `GET /api/locations` response

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "code": "CITYU",
      "name": "City University Campus",
      "description": "Main campus in Abu Samra, Tripoli",
      "type": "campus",
      "floor": 0,
      "latitude": 34.41845,
      "longitude": 35.83539
    }
  ]
}
```

### Example `GET /api/navigation?from=2&to=4` response

```json
{
  "success": true,
  "total_distance": 180,
  "path": [
    { "id": 2, "code": "ADMIN", "name": "Administration" },
    { "id": 3, "code": "LIB", "name": "Central Library" },
    { "id": 4, "code": "KABA", "name": "KABA" }
  ]
}
```

---

## 7. Admin module coherence

`AdminNavigationScreen` in Flutter is the UI for this DB module:

| Admin action (UI) | DB operation |
|-------------------|--------------|
| Open navigation preview | `SELECT` locations |
| Add location (soon) | `INSERT INTO locations` |
| Edit / remove (later) | `UPDATE` / `DELETE` |
| Manage routes (later) | CRUD on `location_edges` |

Attendance Admin uses **different tables** in the same or another D1 DB — see doc 04. Prefer **same `cityu` D1** for both `locations` + attendance tables to keep one binding.

---

## 8. Checklist

### Done
- [x] D1 database `cityu` created  
- [x] Table `locations` with id/code/name/description/lat/lng  
- [x] Seed buildings: CITYU, ADMIN, LIB, KABA, SHOUMAN  

### Next (recommended)
- [ ] Fill latitude/longitude for all rows  
- [ ] Add `type`, `floor`, `is_active` columns  
- [ ] Create `location_edges` + sample distances  
- [ ] Confirm Worker is bound to D1 `cityu` as `DB`  
- [ ] Step 2: implement `CloudflareNavigationRepository` in Flutter  

---

## 9. Quick mental model

```text
locations        = places on campus (what you already built) ✅
location_edges   = walkable links between places             ⬜
Worker API       = secure door from Flutter → D1             (partially ready)
Flutter Nav UI   = already designed; still on mock data      (Step 1)
```

Your current `locations` table is **coherent** with the architecture. Complete coordinates + add `location_edges`, then we wire the Flutter repository in the next implementation step.
