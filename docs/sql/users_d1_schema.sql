-- SmartUni Users — Cloudflare D1 database: users
-- Worker: users.khaledothman750.workers.dev  (binding DB → users)
--
-- If you already have a simple table (username, password, isAdmin),
-- either migrate with the ALTER/UPDATE section below, or recreate fresh.

-- =========================
-- RECOMMENDED SCHEMA
-- =========================
CREATE TABLE IF NOT EXISTS users (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  username      TEXT NOT NULL UNIQUE,          -- login id (student id or admin username)
  password      TEXT NOT NULL,                 -- Step 1 style (hash later in production)
  full_name     TEXT,
  email         TEXT,
  role          TEXT NOT NULL DEFAULT 'student', -- student | admin
  faculty       TEXT,
  is_active     INTEGER NOT NULL DEFAULT 1,
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- =========================
-- SEED (matches Flutter demo logins)
-- =========================
INSERT OR IGNORE INTO users (username, password, full_name, email, role, faculty) VALUES
  ('student', 'student', 'Khaled Othman', '202110142@st.cityu.edu.lb', 'student', 'Engineering Faculty'),
  ('admin', 'admin', 'Campus Administrator', 'admin@cityu.edu.lb', 'admin', 'Administration');

-- =========================
-- OPTIONAL: migrate old schema (username, password, isAdmin)
-- Run only if your old columns exist
-- =========================
-- ALTER TABLE users ADD COLUMN full_name TEXT;
-- ALTER TABLE users ADD COLUMN email TEXT;
-- ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'student';
-- ALTER TABLE users ADD COLUMN faculty TEXT;
-- ALTER TABLE users ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
-- ALTER TABLE users ADD COLUMN created_at TEXT DEFAULT (datetime('now'));
-- UPDATE users SET role = 'admin' WHERE isAdmin = 1 OR isAdmin = '1' OR isAdmin = true;
-- UPDATE users SET role = 'student' WHERE role IS NULL OR role = '';
