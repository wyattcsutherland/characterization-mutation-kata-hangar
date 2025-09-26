import pytest
from gilded_rose import Item, GildedRose


class TestSecretTest2:
    def test_aged_brie_sellin_degraded_by_one_and_quality_increase_by_one(self):
        items = [Item("Aged Brie", 5, 5)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "4, 6"

    def test_aged_brie_sellin_degrade_by_one_and_quality_remain_same(self):
        items = [Item("Aged Brie", 5, 51)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "4, 51"

    def test_aged_brie_sellin_degrade_by_one_and_quality_increase_by_one(self):
        items = [Item("Aged Brie", 8, 40)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "7, 41"

    def test_backstage_passes_selling_degrade_one_quality_stay_the_same(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", 0, 0)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-1, 0"

    def test_backstage_when_sellin_less_than_eleven_quality_less_than_fifty(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", 10, 40)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "9, 42"

    def test_backstage_when_sellin_is_five_quality_is_forty_sellin_decrease_by_one_quality_increase_by_three(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", 5, 40)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "4, 43"