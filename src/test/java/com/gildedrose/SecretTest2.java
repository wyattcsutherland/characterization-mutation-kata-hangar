package com.gildedrose;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
class SecretTest2 {

    @Test
    void agedBrieSellinDegradedByOneAndQualityIncreaseByOne() {
        Item[] items = new Item[] { new Item("Aged Brie", 5,5 ) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("4, 6", actual);
    }

    @Test
    void agedBrieSellinDegradeByOneAndQualityRemainSame() {
        Item[] items = new Item[] { new Item("Aged Brie", 5,51 ) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("4, 51", actual);
    }

    @Test
    void agedBrieSellinDegradeByOneAndQualityIncreaseByOne() {
        Item[] items = new Item[] { new Item("Aged Brie", 8,40) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("7, 41", actual);
    }

    @Test
    void backstagePassesSellingDegradeOneQualityStayTheSame() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 0, 0) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("-1, 0", actual);
    }

    @Test
    void backstageWhenSellinLessThanElevenQualityLessThanFifty() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 10, 40) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("9, 42", actual);
    }

    @Test
    void backstageWhenSellinIsFiveQualityIsFortySellinDecreaseByOneQualityIncreaseByThree() {
        Item[] items = new Item[] { new Item("Backstage passes to a TAFKAL80ETC concert", 5, 40) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].itemsToSellInTime + ", " + app.items[0].quality;
        assertEquals("4, 43", actual);
    }

}
