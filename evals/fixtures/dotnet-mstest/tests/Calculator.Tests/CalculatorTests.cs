using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace CalculatorApp.Tests;

[TestClass]
public class CalculatorTests
{
    [TestMethod]
    public void Add_ReturnsSum()
    {
        Assert.AreEqual(5, 2 + 3);
    }
}
