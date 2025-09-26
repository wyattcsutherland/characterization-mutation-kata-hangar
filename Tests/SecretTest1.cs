using Xunit;

namespace GildedRose.Tests;

public class SecretTest1
{
    [Fact]
    public void AgedBrieSellinDegradesByOneQualityIncreasesByTwo()
    {
        Item[] items = new Item[] { new Item("Aged Brie", 0, 0) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-1, 2", actual);
    }

    [Fact]
    public void BackStagePassesWhenSellInIsLessThanZeroQualityIsZero()
    {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", -5, 40) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-6, 0", actual);
    }

    [Fact]
    public void NormalItem_sellIn_decreases_by_one_and_quality_decreases_by_two()
    {
        Item[] items = new Item[] { new Item("Foo Butter", -5, 40) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-6, 38", actual);
    }

    [Fact]
    public void RegularItemWithSellInLessThanZeroAndQualityEqualsOneThenSellinDegradeByOneAndQualityDegradeByTwo()
    {
        Item[] items = new Item[] { new Item("Ragnaros", -1, 5) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-2, 3", actual);
    }

    [Fact]
    public void RegularItemWhenSellinDegradesByOneQuallityRemaoinsTheSame()
    {
        Item[] items = new Item[] { new Item("foo", 0, 0) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-1, 0", actual);
    }

    [Fact]
    public void AgedBrieSellingNegativeTenQualityZeroSellingDegradedByOneQualityIncreasedByTwo()
    {
        Item[] items = new Item[] { new Item("Aged Brie", -10, 0) };

        var app = new GildedRose(items);
        app.Process();

        string actual = app.Items[0].SellIn + ", " + app.Items[0].Quality;
        Assert.Equal("-11, 2", actual);
    }
}