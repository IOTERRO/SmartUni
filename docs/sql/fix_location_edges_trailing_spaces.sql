-- Fix location_edges: column names accidentally created with trailing spaces
-- Run in D1 Console → cityu

DROP TABLE IF EXISTS location_edges;

CREATE TABLE location_edges (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  from_location_id   INTEGER NOT NULL,
  to_location_id     INTEGER NOT NULL,
  distance_meters    REAL NOT NULL,
  path_type          TEXT DEFAULT 'walk',
  is_bidirectional   INTEGER NOT NULL DEFAULT 1,
  created_at         TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (from_location_id, to_location_id)
);

INSERT INTO location_edges (from_location_id, to_location_id, distance_meters, path_type, is_bidirectional) VALUES
  (1, 2, 90,  'walk', 1),
  (1, 3, 140, 'walk', 1),
  (1, 4, 160, 'walk', 1),
  (1, 5, 40,  'walk', 1),
  (2, 3, 70,  'walk', 1),
  (3, 4, 30,  'walk', 1),
  (4, 5, 140, 'walk', 1);

-- Verify no trailing spaces in names:
PRAGMA table_info(location_edges);
