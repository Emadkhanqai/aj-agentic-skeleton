# Standard: Standard API Response Format

Every API response — success or failure — uses a shared response wrapper so clients get a
predictable envelope with a correlation id and stable machine-readable error codes.

## The wrapper

Lives in backend contracts/common models: `{{ProjectName}}.Contracts.Common`.

```csharp
using System.Text.Json.Serialization;

namespace {{ProjectName}}.Contracts.Common;

public class ApiResponse<T>
{
    [JsonPropertyName("success")]
    public bool IsSuccess { get; set; }

    [JsonPropertyName("data")]
    public T? Data { get; set; }

    [JsonPropertyName("message")]
    public string? Message { get; set; }

    [JsonPropertyName("errors")]
    public List<string>? Errors { get; set; }

    [JsonPropertyName("statusCode")]
    public int StatusCode { get; set; } = 200;

    [JsonPropertyName("code")]
    public string? Code { get; set; }

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [JsonPropertyName("traceId")]
    public string? TraceId { get; set; }

    public static ApiResponse<T> Success(T data, string? message = null, int statusCode = 200)
    {
        return new ApiResponse<T>
        {
            IsSuccess = true,
            Data = data,
            Message = message,
            StatusCode = statusCode
        };
    }

    public static ApiResponse<T> Failure(string message, int statusCode = 400, string? code = null, List<string>? errors = null)
    {
        return new ApiResponse<T>
        {
            IsSuccess = false,
            Message = message,
            Code = code,
            Errors = errors,
            StatusCode = statusCode
        };
    }

    public static ApiResponse<T> SuccessResult(T data, string? message = null)
    {
        return Success(data, message);
    }

    public static ApiResponse<T> ErrorResult(string message, string? code = null, List<string>? errors = null)
    {
        return Failure(message, 400, code, errors);
    }
}

public class ApiResponse
{
    [JsonPropertyName("success")]
    public bool Success { get; set; }

    [JsonPropertyName("message")]
    public string? Message { get; set; }

    [JsonPropertyName("errors")]
    public List<string>? Errors { get; set; }

    [JsonPropertyName("code")]
    public string? Code { get; set; }

    [JsonPropertyName("timestamp")]
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    [JsonPropertyName("traceId")]
    public string? TraceId { get; set; }

    public static ApiResponse CreateSuccess(string? message = null)
    {
        return new ApiResponse
        {
            Success = true,
            Message = message
        };
    }

    public static ApiResponse CreateError(string message, string? code = null, List<string>? errors = null)
    {
        return new ApiResponse
        {
            Success = false,
            Message = message,
            Code = code,
            Errors = errors
        };
    }
}
```

## Rules

- **Every successful API response uses `ApiResponse<T>`** (or `ApiResponse` for no-payload success).
- **Every failed API response uses `ApiResponse<T>` or `ApiResponse`.**
- **`traceId` is always populated** from `Activity.Current?.Id ?? HttpContext.TraceIdentifier`
  — set centrally in the response-wrapping/exception middleware, not per controller.
- **Validation errors go in `errors`** (a flat list of human-readable messages); `code`
  carries the stable machine-readable error code.
- **`code` is a stable, machine-readable error code** (e.g. `BUDGET_NOT_FOUND`,
  `BUDGET_LOCKED`, `VALIDATION_FAILED`, `RATE_CARD_FORBIDDEN`). Codes are documented and
  never repurposed.
- **Never expose stack traces, SQL errors, or internal exception messages** to the client.
  In production, unexpected errors return a generic message + `code` + `traceId`; details go
  to logs/telemetry only (see [`error-handling.md`](error-handling.md)).

## Interop with ProblemDetails

RFC 7807 `ProblemDetails` remains valid for framework-level failures (model-binding, 404
routing). Where both apply, prefer the `ApiResponse` envelope for application/business
responses and keep `ProblemDetails` for pipeline/framework faults, ensuring `traceId`
appears in both. Document both shapes in OpenAPI (see [`swagger-openapi.md`](swagger-openapi.md)).

## Related
[`error-handling.md`](error-handling.md) · [`middleware.md`](middleware.md) · [`observability-tracing.md`](observability-tracing.md) · [`api-versioning.md`](api-versioning.md)
