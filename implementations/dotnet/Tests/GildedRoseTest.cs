using Xunit;

namespace GildedRose.Tests;

public class GildedRoseTest
{
    [Fact]
    public void IntroTest()
    {
        Item[] items = new Item[] { new Item("Paisley Pajama Pants", 5, 10) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("0, 0", actual);
    }
}