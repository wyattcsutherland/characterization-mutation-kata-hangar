package com.gildedrose;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class GildedRoseTest {

    @Test
    void intro_implementation_test() {
        Item[] items = new Item[]{new Item("Paisley Pajama Pants", 5, 10)};

        GildedRose app = new GildedRose(items);
        int beforeSellIn = app.items[0].sellIn;
        int beforeQuality = app.items[0].quality;

        app.process();

        // verify normal items, sellIn is decremented by 1
        assertEquals(beforeSellIn - 1, app.items[0].sellIn);

        // verify normal items, quality is decremented by 1
        assertEquals(beforeQuality - 1, app.items[0].quality);
    }

    @Test
    void intro_behavioral_test() {
        Item[] items = new Item[]{new Item("Paisley Pajama Pants", 5, 10)};

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("0, 0", actual);
    }
}
