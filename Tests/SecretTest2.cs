using Xunit;

namespace GildedRose.Tests;

public class SecretTest2
{
    [Fact]
    public void AgedBrieSellinDegradedByOneAndQualityIncreaseByOne()
    {
        Item[] items = new Item[] { new Item("Aged Brie", 5, 5) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("4, 6", actual);
    }

    [Fact]
    public void AgedBrieSellinDegradeByOneAndQualityRemainSame()
    {
        Item[] items = new Item[] { new Item("Aged Brie", 5, 51) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("4, 51", actual);
    }

    [Fact]
    public void AgedBrieSellinDegradeByOneAndQualityIncreaseByOne()
    {
        Item[] items = new Item[] { new Item("Aged Brie", 8, 40) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("7, 41", actual);
    }

    [Fact]
    public void BackstagePassesSellingDegradeOneQualityStayTheSame()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 0, 0) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-1, 0", actual);
    }

    [Fact]
    public void BackstageWhenSellinLessThanElevenQualityLessThanFifty()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 10, 40) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("9, 42", actual);
    }

    [Fact]
    public void BackstageWhenSellinIsFiveQualityIsFortySellinDecreaseByOneQualityIncreaseByThree()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 5, 40) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("4, 43", actual);
    }
}