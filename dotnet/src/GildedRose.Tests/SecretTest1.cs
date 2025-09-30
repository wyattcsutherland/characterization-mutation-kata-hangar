using NUnit.Framework;

namespace GildedRose.Tests;

[TestFixture]
public class SecretTest1
{
    [Test]
    public void AgedBrieIncreasesQuality()
    {
        Item[] items = { new Item("Aged Brie", 2, 0) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(1));
    }

    [Test]
    public void QualityNeverExceedsFifty()
    {
        Item[] items = { new Item("Aged Brie", 0, 50) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.LessThanOrEqualTo(50));
    }
}