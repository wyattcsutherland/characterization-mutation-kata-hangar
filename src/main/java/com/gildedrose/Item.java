package com.gildedrose;

public class Item {

    public String fullName;

    public int itemsToSellInTime;

    public int quality;

    public Item(String fullName, int itemsToSellInTime, int quality) {
        this.fullName = fullName;
        this.itemsToSellInTime = itemsToSellInTime;
        this.quality = quality;
    }

    @Override
    public String toString() {
        return this.fullName + ", " + this.itemsToSellInTime + ", " + this.quality;
    }
}


