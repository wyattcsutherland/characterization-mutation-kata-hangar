import pytest
from gilded_rose import Item, GildedRose


class TestSecretTest3:
    def test_backstage_selling_ten_quality_sixty_selling_grades_by_one_quality_stays_the_same(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", 10, 60)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "9, 60"

    def test_backstage_sellin_negative_ten_quality_sixty_sellin_degrades_by_one_quality_is_zero(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", -10, 20)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-11, 0"

    def test_sulfuras_sellin_and_quality_always_stays_the_same(self):
        items = [Item("Sulfuras, Hand of Ragnaros", -2, 20)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-2, 20"

    def test_regular_item_quality_greater_than_one_then_sellin_and_quality_decreases_by_one(self):
        items = [Item("Ragnaros", 1, 3)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "0, 2"

    def test_regular_item_with_sellin_less_than_zero_and_quality_zero_then_sellin_degrade_by_one_and_quality_remains_same(self):
        items = [Item("Ragnaros", -1, 0)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-2, 0"

    def test_aged_brie_selling_greater_than_zero_quality_greater_than_49_then_selling_degrade_by_one_quality_remain_same(self):
        items = [Item("Aged Brie", 1, 50)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "0, 50"