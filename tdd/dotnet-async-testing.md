# Async Testing in NUnit (.NET)

## Basics

NUnit awaits `async Task` test methods automatically. Always use `async Task`, never `async void`.

```csharp
[Test]
public async Task FetchUser_ValidId_ReturnsUser()
{
    var user = await _service.FetchAsync(42);
    Assert.That(user.Id, Is.EqualTo(42));
}

// With expected return value
[Test(ExpectedResult = 4)]
public async Task<int> Compute_TwoPlusTwo_ReturnsFour()
{
    await Task.Yield();
    return 2 + 2;
}
```

## Async SetUp / TearDown

All lifecycle methods support `async Task`:

```csharp
[TestFixture]
public class ApiTests
{
    private HttpClient _client;

    [OneTimeSetUp]
    public async Task StartServer()
    {
        _client = new HttpClient { BaseAddress = new Uri("http://localhost:5000") };
        await _client.GetAsync("/health");  // warm up
    }

    [SetUp]
    public async Task ResetState() => await _repo.ClearAsync();

    [OneTimeTearDown]
    public async Task StopServer()
    {
        _client.Dispose();
        await Task.CompletedTask;
    }
}
```

## Parameterized Async

`[TestCase]` and `[TestCaseSource]` work with async:

```csharp
[TestCase(1, ExpectedResult = 2)]
[TestCase(5, ExpectedResult = 10)]
public async Task<int> Double_ReturnsDoubled(int x)
{
    await Task.Yield();
    return x * 2;
}
```

## Exception Testing (Async)

```csharp
[Test]
public async Task Save_NullInput_ThrowsArgumentNullException()
{
    Assert.That(
        async () => await _repo.SaveAsync(null),
        Throws.ArgumentNullException
    );
}
```

## Timeout

```csharp
[Test]
[Timeout(3000)]  // milliseconds — fails if test exceeds limit
public async Task Process_CompletesWithinTimeout()
{
    await _svc.ProcessAsync(CancellationToken.None);
}
```

For production use, prefer passing `CancellationToken` rather than relying on `[Timeout]`.

## Rules

| Rule | Reason |
|------|--------|
| `async Task`, not `async void` | `async void` swallows exceptions; NUnit can't catch them |
| No `.Result` / `.Wait()` in async tests | Deadlock risk on sync contexts |
| Test behavior, not timing | `await Task.Delay` + `IsCompleted` tests timing, not correctness |
| One async behavior per test | Same as sync — don't bundle unrelated awaits |

## Bad vs Good

```csharp
// BAD: tests timing, not behavior
[Test]
public async Task BadTest()
{
    var task = _svc.RunAsync();
    await Task.Delay(200);          // fragile
    Assert.That(task.IsCompleted);  // timing assertion
}

// GOOD: tests behavior
[Test]
public async Task GoodTest()
{
    var result = await _svc.RunAsync();
    Assert.That(result.Status, Is.EqualTo("done"));
}
```
