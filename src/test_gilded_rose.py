import pytest
from gilded_rose import Item, GildedRose


class TestGildedRose:
    def test_intro_test(self):
        items = [Item("Paisley Pajama Pants", 5, 10)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "4, 9"

    # Tests from secret test file 1
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

    # Tests from secret test file 2
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

    # Tests from secret test file 3
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