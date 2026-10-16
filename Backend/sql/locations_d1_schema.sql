-- Author / Project Supervisor : Omar Terro
-- GitHub                      : https://github.com/IOTERRO
-- Website                     : https://omarterro.fr
-- Student (FYP)               : Khaled Othman
-- Date                        : 14 October 2026
-- Project                     : SmartUni - Smart University CityU
-- SmartUni Locations — Cloudflare D1 database: cityu
-- Your locations table ALREADY EXISTS. Use this file for:
--   1) optional column upgrades
--   2) location_edges (routing)
--   3) sample edges
-- Run in: Dashboard → D1 → cityu → Console

-- =========================
-- OPTIONAL upgrades on existing locations
-- (skip a line if column already exists)
-- =========================
-- ALTER TABLE locations ADD COLUMN type TEXT;
-- ALTER TABLE locations ADD COLUMN floor INTEGER DEFAULT 0;
-- ALTER TABLE locations ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;

-- UPDATE locations SET type = 'campus',   is_active = 1 WHERE code = 'CITYU';
-- UPDATE locations SET type = 'admin',    is_active = 1 WHERE code = 'ADMIN';
-- UPDATE locations SET type = 'library',  is_active = 1 WHERE code = 'LIB';
-- UPDATE locations SET type = 'building', is_active = 1 WHERE code = 'KABA';
-- UPDATE locations SET type = 'building', is_active = 1 WHERE code = 'SHOUMAN';

-- Fill real coordinates for every building (replace with accurate values):
-- UPDATE locations SET latitude = 34.41845, longitude = 35.83539 WHERE code = 'CITYU';
-- UPDATE locations SET latitude = ?, longitude = ? WHERE code = 'ADMIN';
-- UPDATE locations SET latitude = ?, longitude = ? WHERE code = 'LIB';
-- UPDATE locations SET latitude = ?, longitude = ? WHERE code = 'KABA';
-- UPDATE locations SET latitude = ?, longitude = ? WHERE code = 'SHOUMAN';

-- =========================
-- ROUTING GRAPH
-- =========================
CREATE TABLE IF NOT EXISTS location_edges (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  from_location_id   INTEGER NOT NULL,
  to_location_id     INTEGER NOT NULL,
  distance_meters    REAL NOT NULL,
  path_type          TEXT DEFAULT 'walk',
  is_bidirectional   INTEGER NOT NULL DEFAULT 1,
  created_at         TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (from_location_id, to_location_id),
  FOREIGN KEY (from_location_id) REFERENCES locations(id),
  FOREIGN KEY (to_location_id) REFERENCES locations(id)
);

CREATE INDEX IF NOT EXISTS idx_edges_from ON location_edges(from_location_id);
CREATE INDEX IF NOT EXISTS idx_edges_to ON location_edges(to_location_id);

-- Sample edges (ids match your current locations 1..5)
INSERT OR IGNORE INTO location_edges (from_location_id, to_location_id, distance_meters) VALUES
  (1, 2, 90),
  (1, 3, 140),
  (1, 4, 160),
  (1, 5, 180),
  (2, 3, 70),
  (3, 4, 110),
  (4, 5, 95);

-- =========================
-- Reference: recreate locations ONLY if needed on a fresh DB
-- =========================
-- CREATE TABLE IF NOT EXISTS locations (
--   id INTEGER PRIMARY KEY AUTOINCREMENT,
--   code TEXT NOT NULL UNIQUE,
--   name TEXT NOT NULL,
--   description TEXT,
--   latitude REAL,
--   longitude REAL,
--   type TEXT,
--   floor INTEGER DEFAULT 0,
--   is_active INTEGER NOT NULL DEFAULT 1
-- );
