# Template: React Feature Component

Function component, TS strict, centralised API, generated types, i18n, a11y.

```tsx
// src/features/orders/components/OrderList.tsx
import { useTranslation } from 'react-i18next';
import { useOrders } from '@/features/orders/hooks/useOrders';
import { Spinner } from '@/shared/components/Spinner';

export function OrderList(): JSX.Element {
  const { t } = useTranslation();
  const { data, isLoading, error } = useOrders();

  if (isLoading) return <Spinner aria-label={t('common.loading')} />;
  if (error) return <p role="alert">{t('orders.loadError')}</p>;

  return (
    <ul aria-label={t('orders.listLabel')}>
      {data?.map((b) => (
        <li key={b.id}>{b.title}</li>
      ))}
    </ul>
  );
}
```

```ts
// src/features/orders/hooks/useOrders.ts
import { useQuery } from '@tanstack/react-query';
import { ordersApi } from '@/shared/api/orders'; // centralised, uses generated types

export function useOrders() {
  return useQuery({ queryKey: ['orders'], queryFn: () => ordersApi.list() });
}
```

Rules: no `fetch`/`axios` in components; types from `@/shared/api/generated`; `shared`
never imports `features`/`pages`; strings via i18n. See
[`../standards/react.md`](../standards/react.md).
```
