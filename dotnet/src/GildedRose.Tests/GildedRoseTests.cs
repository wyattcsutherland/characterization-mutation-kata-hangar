using NUnit.Framework;

namespace GildedRose.Tests;

[TestFixture]
public class GildedRoseTests
{
    [Test]
    public void IntroImplementationTest()
    {
        Item[] items = { new Item("Paisley Pajama Pants", 5, 10) };

        var app = new GildedRose(items);
        int beforeSellIn = app.Items[0].SellIn;
        int beforeQuality = app.Items[0].Quality;

        app.Process();

        // verify normal items, sellIn is decremented by 1
        Assert.That(app.Items[0].SellIn, Is.EqualTo(beforeSellIn - 1));

        // verify normal items, quality is decremented by 1
        Assert.That(app.Items[0].Quality, Is.EqualTo(beforeQuality - 1));
    }

    [Test]
    public void IntroBehavioralTest()
    {
        Item[] items = { new Item("Paisley Pajama Pants", 5, 10) };

        var app = new GildedRose(items);
        app.Process();

        string actual = $"{app.Items[0].SellIn}, {app.Items[0].Quality}";
        Assert.That(actual, Is.EqualTo("0, 0"));
    }
}