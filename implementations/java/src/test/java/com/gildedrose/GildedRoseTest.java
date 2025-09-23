package com.gildedrose;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class GildedRoseTest {

   @Test
   void introTest() {
        Item[] items = new Item[] { new Item("Paisley Pajama Pants", 5, 10) };

        GildedRose app = new GildedRose(items);
        app.process();

        String actual = app.items[0].sellIn + ", " + app.items[0].quality;
        assertEquals("0, 0", actual);
    }
}
