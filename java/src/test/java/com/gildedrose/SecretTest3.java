package com.gildedrose;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
class SecretTest3 {

    @Test
    void backstageSellingTenQualitySixtySellingGradesByOneQualityStaysTheSame() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 10, 60) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("9, 60", actual);
    }

    @Test
    void backstageSellinNegativeTenQualitySixtySellinDegradesByOneQualityIsZero() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", -10, 20) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-11, 0", actual);
    }

    @Test
    void sulfurasSellinAndQualityAlwaysStaysTheSame() {
        Item[] items = new Item[] { new Item("Sulfuras, Hand of Ragnaros", -2, 20) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-2, 20", actual);
    }

    @Test
    void regularItemQualityGreaterThanOneThenSellinAndQualityDecreasesByOne() {
        Item[] items = new Item[] { new Item("Ragnaros", 1, 3) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("0, 2", actual);
    }

    @Test
    void regularItemWithSellinLessThanZeroAndQualityZeroThenSellinDegradeByOneAndQualityRemainsSame() {
        Item[] items = new Item[] { new Item("Ragnaros", -1, 0) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("-2, 0", actual);
    }

    @Test
    void agedBrieSellingGreaterThanZeroQualityGreaterThan49ThenSellingDegradebyOneQualityRemainSame() {
        Item[] items = new Item[] { new Item("Aged Brie", 1, 50) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("0, 50", actual);
    }
}
