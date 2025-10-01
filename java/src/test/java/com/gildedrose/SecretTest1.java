package com.gildedrose;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class SecretTest1 {

    @Test
    void agedBrieSellinDegradesByOneQualityIncreasesByTwo() {
        Item[] items = new Item[] { new Item("Aged Brie", 0, 0) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-1, 2", actual);
    }

    @Test
    void backStagePassesWhenSellInIsLessThanZeroQualityIsZero() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", -5, 40) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-6, 0", actual);
    }

    @Test
    void normalItem_sellIn_decreases_by_one_and_quality_decreases_by_two() {
        Item[] items = new Item[] { new Item("Foo Butter", -5, 40) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-6, 38", actual);
    }

    @Test
    void regularItemWithSellInLessThanZeroAndQualityEqualsOneThenSellinDegradeByOneAndQualityDegradeByTwo() {
        Item[] items = new Item[] { new Item("Ragnaros", -1, 5) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-2, 3", actual);
    }

    @Test
    void regularItemWhenSellinDegradesByOneQuallityRemaoinsTheSame() {
        Item[] items = new Item[] { new Item("foo", 0, 0) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-1, 0", actual);
    }

    @Test
    void agedBrieSellingNegativeTenQualityZeroSellingDegradedByOneQualityIncreasedByTwo() {
        Item[] items = new Item[] { new Item("Aged Brie", -10, 0) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-11, 2", actual);
    }

}
