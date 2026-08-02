# Template: Angular Feature Component (standalone · signals · OnPush · PrimeNG)

```typescript
import { ChangeDetectionStrategy, Component, computed, inject, input, signal } from '@angular/core';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { OrdersApiService } from '../data/orders-api.service'; // generated OpenAPI client wrapper

@Component({
  selector: 'app-order-list',
  standalone: true,
  imports: [TableModule, ButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './order-list.component.html',
})
export class OrderListComponent {
  private readonly api = inject(OrdersApiService);

  readonly filter = input<string>('');           // signal input from route/parent
  readonly loading = signal(false);
  readonly orders = signal<OrderDto[]>([]);
  readonly count = computed(() => this.orders().length);

  // Envelope rule: switch on `code`, never on `message`; errors surface via the
  // shared error interceptor — no per-component toast spaghetti.
}
```

Rules: standalone + OnPush + signals only · PrimeNG components, theme tokens for custom bits ·
types from the generated OpenAPI client (`ApiResponse<T>` envelope) · no `any` ·
component >~300 lines gets split · tests alongside (`.spec.ts`, Testing Library style).
