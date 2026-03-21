using NUnit.Framework;

namespace CalculatorApp.Tests;

public class CalculatorTests
{
    [Test]
    public void Add_ReturnsSum()
    {
        Assert.That(2 + 3, Is.EqualTo(5));
    }
}
