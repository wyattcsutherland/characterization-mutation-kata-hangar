import pytest
from gilded_rose import Item, GildedRose


class TestSecretTest1:
    def test_aged_brie_sellin_degrades_by_one_quality_increases_by_two(self):
        items = [Item("Aged Brie", 0, 0)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-1, 2"

    def test_backstage_passes_when_sell_in_is_less_than_zero_quality_is_zero(self):
        items = [Item("Backstage passes to a TAFKAL80ETC concert", -5, 40)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-6, 0"

    def test_normal_item_sell_in_decreases_by_one_and_quality_decreases_by_two(self):
        items = [Item("Foo Butter", -5, 40)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-6, 38"

    def test_regular_item_with_sell_in_less_than_zero_and_quality_equals_one_then_sellin_degrade_by_one_and_quality_degrade_by_two(self):
        items = [Item("Ragnaros", -1, 5)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-2, 3"

    def test_regular_item_when_sellin_degrades_by_one_quality_remains_the_same(self):
        items = [Item("foo", 0, 0)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-1, 0"

    def test_aged_brie_selling_negative_ten_quality_zero_selling_degraded_by_one_quality_increased_by_two(self):
        items = [Item("Aged Brie", -10, 0)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "-11, 2"