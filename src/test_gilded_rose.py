import pytest
from gilded_rose import Item, GildedRose


class TestGildedRose:
    def test_intro_test(self):
        items = [Item("Paisley Pajama Pants", 5, 10)]

        app = GildedRose(items)
        app.process()

        actual = f"{app.items[0].sell_in}, {app.items[0].quality}"
        assert actual == "0, 0"