<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Project                     : SmartUni - Smart University CityU
-->

# SmartUni Backend

Cloudflare Workers + D1 schemas for users, campus navigation, and attendance.

```text
Backend/
├── sql/                         # D1 CREATE TABLE scripts (source of truth)
│   ├── users_d1_schema.sql
│   ├── locations_d1_schema.sql
│   ├── attendance_d1_schema.sql
│   └── fix_location_edges_trailing_spaces.sql
└── worker/                      # Worker JS + per-service READMEs + API test log
    ├── users-worker.js
    ├── navigation-worker.js
    ├── attendance-worker.js
    ├── *_README.md
    └── worker_results_tests.md
```

Parking is **not** here — see `iot/parking_node/` + Firebase.

App docs: [`../docs/OVERVIEW.md`](../docs/OVERVIEW.md) · [`../docs/ARCHITECTURE_DETAILED.md`](../docs/ARCHITECTURE_DETAILED.md).
