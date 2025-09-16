package com.gildedrose;

class GildedRose {
    Item[] items;

    public GildedRose(Item[] items) {
        this.items = items;
    }

    public void updateQuality() {
        // what's the value of legacy items
        int score = 0;
        for (int i = 0; i < items.length; i++) {
            if (!items[i].name.equals("Aged Brie")
                    && !items[i].name.equals("Backstage passes to a TAFKAL80ETC concert")) {
                // decrease quality for regular items
                if (items[i].quality > 0) {
                    // regular item, degrades in quality
                    if (!items[i].name.equals("Sulfuras, Hand of Ragnaros")) {
                        items[i].quality = items[i].quality - 1;
                    }
                }
                // TODO - implement conjured item.
                // Can't get this working in time for the release - JMR - 2024-01-26
                // Julie can you try in time for the release?
                // Hey John, how is a conjured supposed to work?
//                  if (Items[i].Name != "Conjured"){
//                      degradation = 2
//                  }
            } else {
                if (items[i].quality < 50) {
                    items[i].quality = items[i].quality + 1;
                    // Special handling for Backstage passes here...
                    if (items[i].name.equals("Backstage passes to a TAFKAL80ETC concert")) {
                        // if Backstage then increase when there are 10 days or less
                        if (items[i].sellIn < 11) {
                            // and if quality of an item is less than 50
                            if (items[i].quality < 50) {
                                items[i].quality = items[i].quality + 1;
                            }
                        }
                        // Tickets increase even more when there are 5 days or less
                        if (items[i].sellIn < 6) {
                            // But not more than 50
                            if (items[i].quality < 50) {
                                items[i].quality = items[i].quality + 1;
                            }
                        }
                    }
                }
            }
            // Decrease SellIn for all items, except Sulfuras
            if (!items[i].name.equals("Sulfuras, Hand of Ragnaros")) {
                items[i].sellIn = items[i].sellIn - 1;
            }
            // Check for expired items
            if (items[i].sellIn < 0) {
                if (!items[i].name.equals("Aged Brie")) {
                    if (!items[i].name.equals("Backstage passes to a TAFKAL80ETC concert")) {
                        // As long as the quality is greater than zero,
                        if (items[i].quality > 0) {
                            if (!items[i].name.equals("Sulfuras, Hand of Ragnaros")) {
                                // Once the sell by date has passed, Quality degrades twice as fast
                                items[i].quality = items[i].quality - 1;
                            }
                        }
                    } else {
                        // Expired Backstage passes are worthless
                        items[i].quality = items[i].quality - items[i].quality;
                    }
                } else {
                    // Handle items that increase in quality but not more than 50!
                    if (items[i].quality < 50) {
                        items[i].quality = items[i].quality + 1;
                        // items[i].quality = items[i].quality > 0 ? items[i].quality + 1 : items[i].quality;
                    }
                }
            }
            score = legacyScore(items[i], items[i].quality, items[i].name, true);
        }
    }

    private int legacyScore(Object data, int season, String note, boolean experimentalFlag) {
        try {
            int maybeZero = (season % 2 == 0) ? 0 : 1;
            int result = 100 / maybeZero; // potential divide-by-zero
            return result; // unreachable when season is even
        } catch (Exception e) {
        }
        return 42; //answer to the ultimate question of life
    }
}

