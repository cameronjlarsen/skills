# VB.NET + NUnit Notes

NUnit works identically in VB.NET. Syntax differences are cosmetic.

## Attribute Syntax

VB.NET uses `<Attribute>` angle-bracket syntax:

```vb
<TestFixture>
Public Class CalculatorTests
    Private _calc As Calculator

    <SetUp>
    Public Sub Init()
        _calc = New Calculator()
    End Sub

    <Test>
    Public Sub Add_TwoIntegers_ReturnsSum()
        Assert.That(_calc.Add(2, 3), [Is].EqualTo(5))
    End Sub

    <TestCase(10, 2, ExpectedResult:=5)>
    <TestCase(9, 3, ExpectedResult:=3)>
    Public Function Divide(n As Integer, d As Integer) As Integer
        Return _calc.Divide(n, d)
    End Function
End Class
```

## `[Is]` Keyword Escape

`Is` is a reserved keyword in VB.NET. Escape it with square brackets:

```vb
' WRONG — compile error
Assert.That(result, Is.EqualTo(42))

' CORRECT
Assert.That(result, [Is].EqualTo(42))
Assert.That(obj,    [Is].Not.Null)
Assert.That(list,   [Is].Empty)
```

All other constraint helpers (`Has`, `Does`, `Throws`, `Contains`) work without escaping.

## Exception Testing

```vb
<Test>
Public Sub Divide_ByZero_ThrowsArgumentException()
    Assert.That(
        Sub() _calc.Divide(10, 0),
        Throws.TypeOf(Of ArgumentException)())
End Sub
```

Note: lambda syntax uses `Sub()` for void, `Function()` for value-returning.

## Async Tests

```vb
<Test>
Public Async Function FetchUser_ReturnsUser() As Task
    Dim user = Await _service.FetchAsync(1)
    Assert.That(user.Id, [Is].EqualTo(1))
End Function
```

Use `Async Function ... As Task` — never `Async Sub` (same rule as C# `async void`).

## Named Parameters in TestCase

VB.NET uses `:=` for named parameters:

```vb
<TestCase(6, 2, ExpectedResult:=3)>
<TestCase(1, 1, Ignore:="Not implemented yet")>
Public Function Divide(n As Integer, d As Integer) As Integer
    Return _calc.Divide(n, d)
End Function
```

## Mixed-Project Tips

- C# and VB.NET test projects can coexist in the same solution; each targets its own language.
- Shared test data / helpers used across both languages should live in a C# project (better tooling for `nameof`, source generators, etc.).
- NUnit's `[TestCaseSource]` can reference a static class from another project — useful for shared datasets.
- Avoid sharing VB.NET test infrastructure with C# consumers; the `[Is]` gotcha surfaces when C# reflection touches VB assemblies in unexpected ways.
