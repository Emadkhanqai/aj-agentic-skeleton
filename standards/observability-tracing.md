# Standard: Observability & Tracing

Logs, traces, and metrics are correlated end to end. Every response carries a `traceId` the
user can quote to support, and that same id ties together the server-side telemetry.

## Correlation

- **One correlation id per request.** Accept an inbound `X-Correlation-ID`; otherwise use
  `Activity.Current?.Id ?? HttpContext.TraceIdentifier`. Attach it to the logging scope and
  return it as `traceId` in the `ApiResponse` envelope (see [`api-response-format.md`](api-response-format.md)).
- Propagate W3C Trace Context (`traceparent`) on outbound calls (CAD Portal, IdP, email).

## Tracing & metrics (OpenTelemetry + Application Insights)

- Instrument with **OpenTelemetry** (ASP.NET Core, HttpClient, EF Core instrumentation) and
  export to **Azure Application Insights** where available.
- **Custom domain telemetry** on business events: order created, saved, **completed +
  Reference ID issued**, vendor invited/submitted/revised, price-list published, CAD retrieval.
  Emit as spans/metrics with the order id and actor role (never the rate values).
- Track key metrics: request rate/latency/error-rate per endpoint, completion count, vendor
  submission count, Ref-ID issuance latency, cache hit ratio.

## Structured logging

- **Serilog** (or `Microsoft.Extensions.Logging`) with **structured** properties — no string
  concatenation of context. Standard fields: `traceId`, `actorId`, `actorRole`, `route`,
  `statusCode`, `elapsedMs`, `orderId` where relevant.
- Levels: business 4xx → `Information`/`Warning`; unexpected 5xx → `Error` with full detail;
  security events → dedicated category.
- **Never log** secrets, tokens, connection strings, full PII, or **price-list raw values**.
- In Production, logs hold the detail that is kept out of client responses (see
  [`error-handling.md`](error-handling.md)).

## Health

- `/health/live` (liveness) and `/health/ready` (readiness incl. MSSQL, and Redis/Keycloak
  when wired). Used by the Cloud Run health/readiness warmup path and Cloud Monitoring (see [`gcp.md`](gcp.md)).

## Audit vs telemetry

- The **audit log** (append-only, hash-chained, BRD §3.11) is a compliance record and a
  first-class business output — distinct from operational telemetry. Business-critical actions
  go to **both** (audit for governance, telemetry for ops).

## Related
[`error-handling.md`](error-handling.md) · [`api-response-format.md`](api-response-format.md) · [`middleware.md`](middleware.md) · [`gcp.md`](gcp.md)
