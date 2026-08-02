# Workflow: API Change

> **Model routing (do first):** classify the task and recommend a model — see [`../model-routing.md`](../model-routing.md). API *implementation* → **Sonnet**; a breaking *contract/versioning design* decision → **Opus/Fable**. Warn the user if the current model is mismatched before continuing.

Changing the API surface (new endpoint, changed DTO, new version). Keeps contracts safe and
the frontend in sync.

## 1. Classify the change
- **Additive / backward-compatible** (new endpoint, new optional field) → stays in the current
  version.
- **Breaking** (remove/rename field, tighten validation, change type/status semantics, change
  auth) → **new major version** `/api/v2/...`. Never break a contract silently
  ([`../standards/api-versioning.md`](../standards/api-versioning.md)).
- Changes to the **CAD reference-lookup** contract are always treated as breaking — coordinate
  with the MEP/CAD team (BRD §3.10).

## 2. Implement
- Update Contracts DTOs; keep the **`ApiResponse<T>`** envelope
  ([`../standards/api-response-format.md`](../standards/api-response-format.md)).
- **Never bind EF entities**; map DTO → command explicitly (mass-assignment safe).
- Version the route; mark the old version deprecated (`Deprecation`/`Sunset` headers) if superseded.
- Add/adjust **FluentValidation**; return errors in `errors[]` with stable `code`.

## 3. Document (OpenAPI)
- Document the endpoint, request/response models, **all** error responses, auth requirement,
  and the API version group ([`../standards/swagger-openapi.md`](../standards/swagger-openapi.md)).

## 4. Sync frontend types
- Run `/sync` to regenerate `frontend/src/shared/api/generated` from OpenAPI.
- Remove any now-duplicated hand-written DTOs. Update callers to the versioned endpoint.

## 5. Test
- Integration test the new/changed endpoint incl. validation (400) and authorization (403,
  price-list no-leak) paths. Update architecture tests if DTO shape guarantees changed.

## 6. Review & gate
- `/review` then the pre-push quality gate. Confirm no silent contract break and that
  deprecated versions still function during the window. **No push without approval.**
