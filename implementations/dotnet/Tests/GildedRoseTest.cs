using Xunit;

namespace GildedRose.Tests;

public class GildedRoseTest
{
    [Fact]
    public void IntroImplementationTest()
    {
        Item[] items = new Item[] { new Item("Paisley Pajama Pants", 5, 10) };

        var app = new GildedRose(items);
        int beforeSellIn = app.Items[0].SellIn;
        int beforeQuality = app.Items[0].Quality;

        app.Process();

        // verify normal items, sellIn is decremented by 1
        Assert.Equal(beforeSellIn - 1, app.Items[0].SellIn);

        // verify normal items, quality is decremented by 1
        Assert.Equal(beforeQuality - 1, app.Items[0].Quality);
    }

    [Fact]
    public void IntroBehavioralTest()
    {
        Item[] items = new Item[] { new Item("Paisley Pajama Pants", 5, 10) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("0, 0", actual);
    }
}