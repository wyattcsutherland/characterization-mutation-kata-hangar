using NUnit.Framework;

namespace GildedRose.Tests;

[TestFixture]
public class SecretTest2
{
    [Test]
    public void SulfurasNeverDecreasesQuality()
    {
        Item[] items = { new Item("Sulfuras, Hand of Ragnaros", 0, 80) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(80));
    }

    [Test]
    public void SulfurasNeverDecreasesSellIn()
    {
        Item[] items = { new Item("Sulfuras, Hand of Ragnaros", 1, 80) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].SellIn, Is.EqualTo(1));
    }
}