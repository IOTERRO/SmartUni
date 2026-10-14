<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# Users Worker

Source file: **`users-worker.js`**

| Item | Value |
|------|--------|
| Worker | `users` |
| URL | `https://users.khaledothman750.workers.dev` |
| D1 binding | `DB` â†’ `users` |
| Secret | `API_KEY` = `YOUR_CLOUDFLARE_API_KEY` |

> If the Users Worker uses a different secret in Cloudflare, replace the key below.  
> Set it under Worker Settings â†’ Variables and Secrets â†’ `API_KEY`.

## Deploy

1. Open Worker **users** â†’ **Edit code**
2. Replace everything with `users-worker.js`
3. **Save and Deploy**
4. In D1 database **users**, run `docs/sql/users_d1_schema.sql`

## Test

```bash
# Health
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://users.khaledothman750.workers.dev/api/health

# List users (passwords never returned)
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://users.khaledothman750.workers.dev/api/users

# Login student
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"username\":\"student\",\"password\":\"student\"}" \
  https://users.khaledothman750.workers.dev/api/login

# Login admin
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"admin\"}" \
  https://users.khaledothman750.workers.dev/api/login

# Create user
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"username\":\"sara\",\"password\":\"pass123\",\"full_name\":\"Sara Haddad\",\"role\":\"student\"}" \
  https://users.khaledothman750.workers.dev/api/users

# Delete user id 3
curl -X DELETE -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" \
  https://users.khaledothman750.workers.dev/api/users/3
```

## What improved vs your old worker

| Old | New |
|-----|-----|
| Only GET/POST/DELETE on `/` | Clean `/api/...` routes + legacy `/` still works |
| Returns passwords in GET | Passwords never returned |
| `isAdmin` only | Supports `role` (`student`/`admin`) + maps old `isAdmin` |
| No login endpoint | `POST /api/login` for Flutter |
| No CORS | CORS enabled for Flutter web |
| No update | `PUT /api/users/:id` |

Full DB doc: `docs/06_CLOUDFLARE_USERS_DB.md`
