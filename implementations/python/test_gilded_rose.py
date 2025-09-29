import pytest
from gilded_rose import Item, GildedRose


class TestGildedRose:
    def test_intro_implementation_test(self):
        items = [Item("Paisley Pajama Pants", 5, 10)]

        app = GildedRose(items)
        before_sell_in = app.items[0].sell_in
        before_quality = app.items[0].quality

        app.process()

        # verify normal items, sell_in is decremented by 1
        assert app.items[0].sell_in == before_sell_in - 1

        # verify normal items, quality is decremented by 1
        assert app.items[0].quality == before_quality - 1

    def test_intro_behavioral_test(self):
        items = [Item("Paisley Pajama Pants", 5, 10)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "0, 0"