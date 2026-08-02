# Template: Domain Entity ({{ProjectName}}.Domain)

Persistence-ignorant. No EF/ASP.NET attributes. Invariants enforced in the type.

```csharp
namespace {{ProjectName}}.Domain.Orders;

public sealed class Order
{
    private readonly List<OrderLine> _lines = new();

    public int Id { get; private set; }
    public string? ReferenceId { get; private set; }   // BG-YYYY-NNNN, issued on Complete
    public string Title { get; private set; }
    public OrderStatus Status { get; private set; }
    public string CurrencyCode { get; private set; }
    public decimal? ConversionRate { get; private set; } // 1 USD = n [currency]
    public IReadOnlyList<OrderLine> Lines => _lines.AsReadOnly();

    private Order() { Title = null!; CurrencyCode = null!; } // EF

    public Order(string title, string currencyCode)
    {
        if (string.IsNullOrWhiteSpace(title)) throw new DomainException("Title required.");
        Title = title;
        CurrencyCode = currencyCode;
        Status = OrderStatus.Draft;
    }

    public void MarkComplete(Func<string> referenceIdFactory)
    {
        // enforce completeness invariants here, then:
        if (Status != OrderStatus.Draft && Status != OrderStatus.Reopened)
            throw new DomainException("Only a Draft/Reopened order can be completed.");
        ReferenceId ??= referenceIdFactory(); // issued exactly once
        Status = OrderStatus.Complete;
    }
}
```

- Mapping (`decimal(18,4)`, unique index on `ReferenceId`, etc.) goes in an
  `IEntityTypeConfiguration<Order>` in **Infrastructure**, not here.
- See [`../standards/clean-architecture.md`](../standards/clean-architecture.md) and
  [`../standards/ef-core.md`](../standards/ef-core.md).
```
