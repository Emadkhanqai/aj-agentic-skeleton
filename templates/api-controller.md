# Template: API Controller ({{ProjectName}}.Api)

Thin. Dispatch to Application, map to Contracts DTO, return. ProblemDetails on error.

```csharp
namespace {{ProjectName}}.Api.Controllers;

[ApiController]
[Route("api/orders")]
[Produces("application/json")]
public sealed class OrdersController : ControllerBase
{
    private readonly ISender _sender; // mediator/dispatcher into Application

    public OrdersController(ISender sender) => _sender = sender;

    /// <summary>Create a draft order.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(OrderResponse), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create(CreateOrderRequest request, CancellationToken ct)
    {
        var result = await _sender.Send(new CreateOrderCommand(request.Title, request.CurrencyCode), ct);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(OrderResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id, CancellationToken ct)
        => Ok(await _sender.Send(new GetOrderByIdQuery(id), ct));
}
```

Rules: no business logic here; DTOs come from `{{ProjectName}}.Contracts`; validation via
FluentValidation surfaced as `ValidationProblemDetails`; role/scope authorization
enforced (price-list fields filtered per role in Application). See
[`../standards/api-design.md`](../standards/api-design.md).
```
