# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

```csharp
using NUnit.Framework;

[TestFixture]
public sealed class CheckoutTests
{
    [Test]
    public async Task User_can_checkout_with_valid_cart()
    {
        var cart = Cart.Create();
        cart = cart.Add(Product.Standard());
        var result = await Checkout.ExecuteAsync(cart, PaymentMethod.TestCard());

        Assert.That(result.Status, Is.EqualTo(CheckoutStatus.Confirmed));
    }
}
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

```csharp
using Moq;
using NUnit.Framework;

[TestFixture]
public sealed class CheckoutImplementationTests
{
    [Test]
    public async Task Checkout_calls_payment_service_process()
    {
        var payment = new Mock<IPaymentService>();
        var cart = Cart.Create();

        await Checkout.ExecuteAsync(cart, payment.Object);

        payment.Verify(p => p.ProcessAsync(cart.Total), Times.Once);
    }
}
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

```csharp
// BAD: Bypasses interface to verify
[Test]
public async Task CreateUser_saves_to_database()
{
    await userService.CreateUserAsync(new UserDraft("Alice"));

    var row = await db.QuerySingleAsync<UserRow>(
        "SELECT * FROM users WHERE name = @name",
        new { name = "Alice" });

    Assert.That(row, Is.Not.Null);
}

// GOOD: Verifies through interface
[Test]
public async Task CreateUser_makes_user_retrievable()
{
    var user = await userService.CreateUserAsync(new UserDraft("Alice"));
    var retrieved = await userService.GetUserAsync(user.Id);

    Assert.That(retrieved.Name, Is.EqualTo("Alice"));
}
```

## Storage Verification Nuance

Verifying through a database query is usually a weaker test than verifying through a public application interface, because it couples the test to storage details.

Prefer:

- asserting through a public read API when the contract is "this data can now be retrieved"
- asserting through storage only when persistence behavior itself is part of the contract being tested
