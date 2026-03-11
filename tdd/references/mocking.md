# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

**1. Use dependency injection**

Pass external dependencies in rather than creating them internally:

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

```csharp
public sealed class PaymentProcessor
{
    private readonly IPaymentClient _client;

    public PaymentProcessor(IPaymentClient client) => _client = client;

    public Task<ChargeResult> ProcessAsync(Order order) =>
        _client.ChargeAsync(order.Total);
}

public sealed class PaymentProcessorWithHiddenDeps
{
    public Task<ChargeResult> ProcessAsync(Order order)
    {
        var client = new StripeClient("api-key");
        return client.ChargeAsync(order.Total);
    }
}
```

```csharp
using Moq;
using NUnit.Framework;

[Test]
public async Task Processes_payment_through_boundary_client()
{
    var order = Order.Create();
    var client = new Mock<IPaymentClient>();
    client.Setup(c => c.ChargeAsync(order.Total))
        .ReturnsAsync(ChargeResult.Approved);

    var processor = new PaymentProcessor(client.Object);
    var result = await processor.ProcessAsync(order);

    Assert.That(result, Is.EqualTo(ChargeResult.Approved));
}
```

**2. Prefer SDK-style interfaces over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

```csharp
public interface IUserApi
{
    Task<UserDto> GetUserAsync(UserId id, CancellationToken ct);
    Task<IReadOnlyList<OrderDto>> GetOrdersAsync(UserId id, CancellationToken ct);
    Task<OrderDto> CreateOrderAsync(CreateOrderRequest request, CancellationToken ct);
}

public interface IApiClient
{
    Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct);
}
```

The SDK approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint
