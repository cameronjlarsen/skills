# Interface Design for Testability

Good interfaces make testing natural:

1. **Accept dependencies, don't create them**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

   ```csharp
   public sealed class OrderProcessor
   {
       private readonly IPaymentGateway _gateway;

       public OrderProcessor(IPaymentGateway gateway) => _gateway = gateway;

       public Task<PaymentResult> ProcessAsync(Order order) =>
           _gateway.ChargeAsync(order.Total);
   }

   public sealed class OrderProcessorWithHiddenDeps
   {
       public Task<PaymentResult> ProcessAsync(Order order)
       {
           var gateway = new StripeGateway("api-key");
           return gateway.ChargeAsync(order.Total);
       }
   }
   ```

2. **Return results, don't produce side effects**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

   ```csharp
   public sealed record Cart(Money Total)
   {
       public Cart Apply(Discount discount) =>
           this with { Total = Total - discount.Amount };
   }

   public sealed class CartWithSideEffects
   {
       public Money Total { get; private set; }

       public void Apply(Discount discount)
       {
           Total = Total - discount.Amount;
       }
   }
   ```

3. **Small surface area**
   - Fewer methods = fewer tests needed
   - Fewer params = simpler test setup
