using NUnit.Framework;

namespace GildedRose.Tests;

[TestFixture]
public class SecretTest3
{
    [Test]
    public void BackstagePassesIncreaseInValue()
    {
        Item[] items = { new Item("Backstage passes to a TAFKAL80ETC concert", 15, 20) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(21));
    }

    [Test]
    public void BackstagePassesIncreaseBy2When10DaysOrLess()
    {
        Item[] items = { new Item("Backstage passes to a TAFKAL80ETC concert", 10, 20) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(22));
    }

    [Test]
    public void BackstagePassesIncreaseBy3When5DaysOrLess()
    {
        Item[] items = { new Item("Backstage passes to a TAFKAL80ETC concert", 5, 20) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(23));
    }

    [Test]
    public void BackstagePassesDropToZeroAfterConcert()
    {
        Item[] items = { new Item("Backstage passes to a TAFKAL80ETC concert", 0, 20) };
        var app = new GildedRose(items);
        
        app.Process();
        
        Assert.That(items[0].Quality, Is.EqualTo(0));
    }
}