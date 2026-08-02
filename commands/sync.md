---
description: Sync the frontend API layer to the backend OpenAPI — regenerate types, remove duplicated DTOs, and confirm versioned-endpoint usage. Does not push.
---

# /sync

Keep the frontend contract in lockstep with the backend OpenAPI document. Run after any API
change ([`../workflows/api-change.md`](../workflows/api-change.md)).

## Do this
1. Ensure the backend builds and the OpenAPI/Swagger document is current
   (`/swagger/v{version}/swagger.json`) — see [`../standards/swagger-openapi.md`](../standards/swagger-openapi.md).
2. Regenerate frontend types from OpenAPI into `frontend/src/shared/api/generated`
   (`npm run generate:api`, i.e. `openapi-typescript`).
3. **Remove any hand-written DTO** that a generated type now covers — no duplicated backend
   models on the frontend.
4. Confirm all frontend calls use **versioned** endpoints (`/api/v1/...`) and unwrap the
   **`ApiResponse<T>`** envelope centrally (surfacing `traceId` on errors).
5. `npm run typecheck && npm run build` to prove the frontend compiles against the new types.

## Rules
- Generated files are source-controlled but **never hand-edited**.
- If a breaking API change forced a new version, update callers to the new version deliberately;
  do not silently follow a moved contract.

## Output
List regenerated files, any DTOs removed as now-duplicated, and any call sites updated.
**Do not push** — leave the result for review and approval.
