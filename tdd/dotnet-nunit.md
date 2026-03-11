# .NET / NUnit Reference

NUnit for C# and VB.NET. Use `Assert.That()` constraint model throughout — avoid legacy `Assert.AreEqual` style.

## Fixture Structure

```csharp
[TestFixture]  // optional if class contains [Test] methods
public class OrderTests
{
    private OrderService _svc;

    [OneTimeSetUp]  // once per fixture — expensive shared setup
    public void Init() => _svc = new OrderService(new FakeRepo());

    [SetUp]         // before each test — cheap reset
    public void Reset() => _svc.Clear();

    [Test]
    public void Add_ValidItem_IncreasesCount()
    {
        _svc.Add(new Item("Widget", 10m));
        Assert.That(_svc.Count, Is.EqualTo(1));
    }

    [OneTimeTearDown]
    public void Cleanup() => _svc.Dispose();
}
```

VB.NET is identical — use `<TestFixture>`, `<Test>`, etc.

## Assertion Syntax

```csharp
Assert.That(result, Is.EqualTo(42));
Assert.That(obj,    Is.Not.Null);
Assert.That(list,   Has.Count.EqualTo(3));
Assert.That(text,   Does.Contain("prefix"));
Assert.That(value,  Is.GreaterThan(0).And.LessThan(100));

// Exceptions
Assert.That(
    () => svc.Divide(10, 0),
    Throws.TypeOf<ArgumentException>()
          .With.Message.Contains("divisor")
);
```

**VB.NET gotcha:** `Is` is a keyword — use `[Is]`:

```vb
Assert.That(result, [Is].EqualTo(42))
```

## Parameterized Tests

```csharp
// Inline cases — use for ≤5 simple inputs
[TestCase("a@b.com", true)]
[TestCase("bad",     false)]
[TestCase(null,      false)]
public void Validate_Email(string email, bool expected)
    => Assert.That(_validator.IsValid(email), Is.EqualTo(expected));

// Return-value shorthand
[TestCase(6, 2, ExpectedResult = 3)]
[TestCase(9, 3, ExpectedResult = 3)]
public int Divide(int n, int d) => _calc.Divide(n, d);

// External data — use for complex or reusable inputs
[TestCaseSource(nameof(InvalidInputs))]
public void Parse_InvalidInput_Throws(string raw) =>
    Assert.That(() => Parser.Parse(raw), Throws.TypeOf<FormatException>());

private static IEnumerable<TestCaseData> InvalidInputs =>
    new[] { null, "", "???" }.Select(x => new TestCaseData(x));
```

**Execution order is undefined.** Never write tests that depend on ordering of `[TestCase]` attributes.

## Naming Convention

`Method_Condition_ExpectedBehavior` — test names are the spec:

```csharp
Add_DuplicateItem_ThrowsInvalidOperationException
GetDiscount_VipCustomer_Returns10Percent
Parse_NullInput_ThrowsArgumentNullException
```

## Lifecycle Order (inheritance)

```
OneTimeSetUp  (base → derived)
  SetUp       (base → derived)
    Test
  TearDown    (derived → base)
OneTimeTearDown (derived → base)
```

**Override gotcha:** If derived class overrides base `SetUp` without `[SetUp]`, base version won't run. Add `[SetUp]` to both.

## Common Gotchas

- `[Ignore]` on its own line ignores the **whole fixture** — use `[TestCase(..., Ignore = "reason")]` to skip one case.
- `[OneTimeSetUp]` failure blocks **all** tests in the fixture.
- `[TestFixture]` is optional in modern NUnit — but keep it for clarity in VB.NET projects.
- Multiple `[SetUp]` methods in the same class: order is undefined. Use one, or inheritance.
