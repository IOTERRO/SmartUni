/**
 * Author / Project Supervisor : Omar Terro
 * GitHub                      : https://github.com/IOTERRO
 * Website                     : https://omarterro.fr
 * Student (FYP)               : Khaled Othman
 * Date                        : 14 October 2026
 * Project                     : SmartUni - Smart University CityU
 */
/**
 * Smart University Worker — Users / Auth API
 *
 * Cloudflare bindings required:
 *   - D1 Database: env.DB  →  users
 *   - Secret:      env.API_KEY
 *
 * URL: https://users.khaledothman750.workers.dev
 *
 * Paste into: Workers → users → Edit code
 *
 * Compatible with:
 *   - New schema: username, password, full_name, email, role, faculty, is_active
 *   - Old schema: username, password, isAdmin  (mapped to role)
 */

export default {
  async fetch(request, env) {
    try {
      if (request.method === "OPTIONS") {
        return cors(new Response(null, { status: 204 }));
      }

      if (!authorize(request, env)) {
        return json({ success: false, error: "Unauthorized access" }, 401);
      }

      if (!env.DB) {
        return json(
          {
            success: false,
            error: "D1 binding DB is missing. Bind database users as variable DB.",
          },
          500
        );
      }

      const url = new URL(request.url);
      const path = normalizePath(url.pathname);
      const method = request.method.toUpperCase();

      // -------- Auth --------
      if (method === "POST" && path === "/api/login") {
        const body = await readJson(request);
        return cors(await login(env.DB, body));
      }

      // -------- Users CRUD --------
      if (method === "GET" && path === "/api/users") {
        return cors(await listUsers(env.DB));
      }

      if (method === "POST" && path === "/api/users") {
        const body = await readJson(request);
        return cors(await createUser(env.DB, body));
      }

      let match = path.match(/^\/api\/users\/(\d+)$/);
      if (method === "GET" && match) {
        return cors(await getUser(env.DB, Number(match[1])));
      }

      if (method === "PUT" && match) {
        const body = await readJson(request);
        return cors(await updateUser(env.DB, Number(match[1]), body));
      }

      if (method === "DELETE" && match) {
        return cors(await deleteUser(env.DB, Number(match[1])));
      }

      // Legacy DELETE /?id=5 (keep working with your old client)
      if (method === "DELETE" && (path === "/" || path === "/api/users")) {
        const id = url.searchParams.get("id");
        if (!id) {
          return json({ success: false, error: "Missing id" }, 400);
        }
        return cors(await deleteUser(env.DB, Number(id)));
      }

      // Legacy GET / → list users
      if (method === "GET" && path === "/") {
        return cors(await listUsers(env.DB));
      }

      // Legacy POST / → create user
      if (method === "POST" && path === "/") {
        const body = await readJson(request);
        return cors(await createUser(env.DB, body));
      }

      if (method === "GET" && path === "/api/health") {
        return json({
          success: true,
          service: "users",
          database: "users",
          endpoints: [
            "POST /api/login",
            "GET /api/users",
            "GET /api/users/:id",
            "POST /api/users",
            "PUT /api/users/:id",
            "DELETE /api/users/:id",
          ],
        });
      }

      return json({ success: false, error: "Not found", path }, 404);
    } catch (err) {
      return json({ success: false, error: err?.message || String(err) }, 500);
    }
  },
};

// =============================================================================
// Helpers
// =============================================================================

function authorize(request, env) {
  const expectedKey = env.API_KEY;
  const providedKey = request.headers.get("X-API-Key");
  return Boolean(expectedKey && providedKey && providedKey === expectedKey);
}

function normalizePath(pathname) {
  if (!pathname) return "/";
  return pathname.length > 1 && pathname.endsWith("/")
    ? pathname.slice(0, -1)
    : pathname;
}

function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, X-API-Key, Authorization",
    "Access-Control-Max-Age": "86400",
  };
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(),
    },
  });
}

function cors(response) {
  const headers = new Headers(response.headers);
  for (const [k, v] of Object.entries(corsHeaders())) {
    headers.set(k, v);
  }
  return new Response(response.body, { status: response.status, headers });
}

async function readJson(request) {
  try {
    return await request.json();
  } catch {
    throw new Error("Invalid JSON body");
  }
}

async function tableHasColumn(db, table, column) {
  const info = await db.prepare(`PRAGMA table_info(${table})`).all();
  return (info.results || []).some((c) => c.name === column);
}

function resolveRole(row) {
  if (row.role) return String(row.role).toLowerCase();
  const adminFlag = row.isAdmin ?? row.is_admin;
  if (adminFlag === 1 || adminFlag === true || adminFlag === "1" || adminFlag === "true") {
    return "admin";
  }
  return "student";
}

/** Never expose password in API responses */
function publicUser(row) {
  if (!row) return null;
  return {
    id: row.id,
    username: row.username,
    full_name: row.full_name ?? row.fullName ?? null,
    email: row.email ?? null,
    role: resolveRole(row),
    faculty: row.faculty ?? null,
    is_active: row.is_active === undefined || row.is_active === null ? 1 : row.is_active,
    created_at: row.created_at ?? null,
  };
}

// =============================================================================
// Auth
// =============================================================================

async function login(db, body) {
  const username = String(body?.username || body?.universityId || body?.email || "").trim();
  const password = String(body?.password || "");

  if (!username || !password) {
    return json(
      { success: false, error: "username and password are required" },
      400
    );
  }

  const row = await db
    .prepare("SELECT * FROM users WHERE LOWER(username) = LOWER(?)")
    .bind(username)
    .first();

  if (!row || String(row.password) !== password) {
    return json({ success: false, error: "Invalid username or password" }, 401);
  }

  const hasActive = await tableHasColumn(db, "users", "is_active");
  if (hasActive && Number(row.is_active) === 0) {
    return json({ success: false, error: "Account is disabled" }, 403);
  }

  const user = publicUser(row);
  return json({
    success: true,
    user,
    // Flutter AppUser mapping helpers
    token: `demo-${user.role}-${user.id}`, // replace with real JWT later
  });
}

// =============================================================================
// Users CRUD
// =============================================================================

async function listUsers(db) {
  const hasActive = await tableHasColumn(db, "users", "is_active");
  const sql = hasActive
    ? "SELECT * FROM users WHERE is_active = 1 ORDER BY id ASC"
    : "SELECT * FROM users ORDER BY id ASC";

  const { results } = await db.prepare(sql).all();
  return json({
    success: true,
    data: (results || []).map(publicUser),
  });
}

async function getUser(db, id) {
  const row = await db.prepare("SELECT * FROM users WHERE id = ?").bind(id).first();
  if (!row) return json({ success: false, error: "User not found" }, 404);
  return json({ success: true, data: publicUser(row) });
}

async function createUser(db, body) {
  const username = String(body?.username || "").trim();
  const password = String(body?.password || "");
  const fullName = body?.full_name ?? body?.fullName ?? null;
  const email = body?.email ?? null;
  const faculty = body?.faculty ?? null;

  // role from role field OR legacy isAdmin
  let role = String(body?.role || "").toLowerCase();
  if (!role) {
    const adminFlag = body?.isAdmin ?? body?.is_admin;
    role =
      adminFlag === 1 || adminFlag === true || adminFlag === "1" || adminFlag === "true"
        ? "admin"
        : "student";
  }
  if (role !== "admin" && role !== "student") {
    return json({ success: false, error: "role must be student or admin" }, 400);
  }

  if (!username || !password) {
    return json(
      { success: false, error: "Missing required fields: username, password" },
      400
    );
  }

  const hasRole = await tableHasColumn(db, "users", "role");
  const hasIsAdmin = await tableHasColumn(db, "users", "isAdmin");
  const hasFullName = await tableHasColumn(db, "users", "full_name");
  const hasEmail = await tableHasColumn(db, "users", "email");
  const hasFaculty = await tableHasColumn(db, "users", "faculty");
  const hasActive = await tableHasColumn(db, "users", "is_active");

  // Build INSERT dynamically for old/new schema
  const cols = ["username", "password"];
  const vals = [username, password];

  if (hasFullName) {
    cols.push("full_name");
    vals.push(fullName);
  }
  if (hasEmail) {
    cols.push("email");
    vals.push(email);
  }
  if (hasRole) {
    cols.push("role");
    vals.push(role);
  }
  if (hasIsAdmin) {
    cols.push("isAdmin");
    vals.push(role === "admin" ? 1 : 0);
  }
  if (hasFaculty) {
    cols.push("faculty");
    vals.push(faculty);
  }
  if (hasActive) {
    cols.push("is_active");
    vals.push(1);
  }

  const placeholders = cols.map(() => "?").join(", ");
  const sql = `INSERT INTO users (${cols.join(", ")}) VALUES (${placeholders})`;

  try {
    const info = await db.prepare(sql).bind(...vals).run();
    const id = info.meta?.last_row_id;
    const row = await db.prepare("SELECT * FROM users WHERE id = ?").bind(id).first();
    return json({ success: true, message: "User added", data: publicUser(row) }, 201);
  } catch (e) {
    if (String(e.message || e).includes("UNIQUE")) {
      return json({ success: false, error: "Username already exists" }, 409);
    }
    throw e;
  }
}

async function updateUser(db, id, body) {
  const existing = await db.prepare("SELECT * FROM users WHERE id = ?").bind(id).first();
  if (!existing) return json({ success: false, error: "User not found" }, 404);

  const hasRole = await tableHasColumn(db, "users", "role");
  const hasIsAdmin = await tableHasColumn(db, "users", "isAdmin");
  const hasFullName = await tableHasColumn(db, "users", "full_name");
  const hasEmail = await tableHasColumn(db, "users", "email");
  const hasFaculty = await tableHasColumn(db, "users", "faculty");
  const hasActive = await tableHasColumn(db, "users", "is_active");

  const username =
    body.username !== undefined ? String(body.username).trim() : existing.username;
  const password =
    body.password !== undefined ? String(body.password) : existing.password;

  const sets = ["username = ?", "password = ?"];
  const vals = [username, password];

  if (hasFullName && body.full_name !== undefined) {
    sets.push("full_name = ?");
    vals.push(body.full_name);
  }
  if (hasEmail && body.email !== undefined) {
    sets.push("email = ?");
    vals.push(body.email);
  }
  if (hasFaculty && body.faculty !== undefined) {
    sets.push("faculty = ?");
    vals.push(body.faculty);
  }
  if (hasActive && body.is_active !== undefined) {
    sets.push("is_active = ?");
    vals.push(Number(body.is_active));
  }

  let role = null;
  if (body.role !== undefined) {
    role = String(body.role).toLowerCase();
  } else if (body.isAdmin !== undefined || body.is_admin !== undefined) {
    const adminFlag = body.isAdmin ?? body.is_admin;
    role =
      adminFlag === 1 || adminFlag === true || adminFlag === "1" || adminFlag === "true"
        ? "admin"
        : "student";
  }

  if (role) {
    if (role !== "admin" && role !== "student") {
      return json({ success: false, error: "role must be student or admin" }, 400);
    }
    if (hasRole) {
      sets.push("role = ?");
      vals.push(role);
    }
    if (hasIsAdmin) {
      sets.push("isAdmin = ?");
      vals.push(role === "admin" ? 1 : 0);
    }
  }

  vals.push(id);
  await db
    .prepare(`UPDATE users SET ${sets.join(", ")} WHERE id = ?`)
    .bind(...vals)
    .run();

  const row = await db.prepare("SELECT * FROM users WHERE id = ?").bind(id).first();
  return json({ success: true, data: publicUser(row) });
}

async function deleteUser(db, id) {
  const existing = await db.prepare("SELECT * FROM users WHERE id = ?").bind(id).first();
  if (!existing) return json({ success: false, error: "User not found" }, 404);

  const hasActive = await tableHasColumn(db, "users", "is_active");
  if (hasActive) {
    await db.prepare("UPDATE users SET is_active = 0 WHERE id = ?").bind(id).run();
    return json({ success: true, message: `User ${id} deactivated` });
  }

  await db.prepare("DELETE FROM users WHERE id = ?").bind(id).run();
  return json({ success: true, message: `User ${id} deleted` });
}
