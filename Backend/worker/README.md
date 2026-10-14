<!--
  Author / Project Supervisor : Omar Terro
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni — Smart University CityU
-->
# Smart University Worker (Locations / Navigation)

Replace the current Worker code (API key only â†’ `"Access Granted!"`) with:

**`smart-university-worker.js`**

## Cloudflare setup (you already have most of this)

| Binding / Secret | Name | Value |
|------------------|------|--------|
| D1 Database | `DB` | `cityu` |
| Secret | `API_KEY` | `YOUR_CLOUDFLARE_API_KEY` |
| Route | â€” | `smart-university.khaledothman750.workers.dev` |

> Keep this key in Cloudflare **Secrets** as `API_KEY` (Worker Settings â†’ Variables and Secrets).  
> Do not put your Cloudflare account password in this repo.

### Deploy steps

1. Open Worker **smart-university** â†’ **Edit code**
2. Delete the old script
3. Paste the full contents of `smart-university-worker.js`
4. **Save and Deploy**
5. In D1 `cityu`, create `location_edges` (see `docs/sql/locations_d1_schema.sql`) so `/api/navigation` works

## Test with curl

```bash
# Health
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://smart-university.khaledothman750.workers.dev/api/health

# List locations
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://smart-university.khaledothman750.workers.dev/api/locations

# Search
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" "https://smart-university.khaledothman750.workers.dev/api/locations/search?q=lib"

# Route (after location_edges exists)
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" "https://smart-university.khaledothman750.workers.dev/api/navigation?from=2&to=4"

# Create location (admin)
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"code\":\"GATE\",\"name\":\"Main Gate\",\"description\":\"Entrance\"}" \
  https://smart-university.khaledothman750.workers.dev/api/locations
```

## Endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/health` | List available routes |
| GET | `/api/locations` | All locations |
| GET | `/api/locations/search?q=` | Filter |
| GET | `/api/navigation?from=&to=` | id or code |
| POST | `/api/locations` | Add |
| PUT | `/api/locations/:id` | Update |
| DELETE | `/api/locations/:id` | Soft delete if `is_active` exists |

All routes (except `OPTIONS`) require header:

`X-API-Key: YOUR_CLOUDFLARE_API_KEY`
