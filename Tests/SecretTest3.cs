using Xunit;

namespace GildedRose.Tests;

public class SecretTest3
{
    [Fact]
    public void BackstageSellingTenQualitySixtySellingGradesByOneQualityStaysTheSame()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 10, 60) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("9, 60", actual);
    }

    [Fact]
    public void BackstageSellinNegativeTenQualitySixtySellinDegradesByOneQualityIsZero()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", -10, 20) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-11, 0", actual);
    }

    [Fact]
    public void SulfurasSellinAndQualityAlwaysStaysTheSame()
    {
        Item[] items = new Item[] { new Item("Sulfuras, Hand of Ragnaros", -2, 20) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-2, 20", actual);
    }

    [Fact]
    public void RegularItemQualityGreaterThanOneThenSellinAndQualityDecreasesByOne()
    {
        Item[] items = new Item[] { new Item("Ragnaros", 1, 3) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("0, 2", actual);
    }

    [Fact]
    public void RegularItemWithSellinLessThanZeroAndQualityZeroThenSellinDegradeByOneAndQualityRemainsSame()
    {
        Item[] items = new Item[] { new Item("Ragnaros", -1, 0) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-2, 0", actual);
    }

    [Fact]
    public void AgedBrieSellingGreaterThanZeroQualityGreaterThan49ThenSellingDegradebyOneQualityRemainSame()
    {
        Item[] items = new Item[] { new Item("Aged Brie", 1, 50) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("0, 50", actual);
    }
}