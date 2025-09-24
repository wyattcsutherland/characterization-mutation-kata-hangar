# GildedRose Python Implementation

This is a Python implementation of the GildedRose kata, equivalent to the Java and .NET versions.

## Prerequisites

- Python 3.8 or later
- pip (Python package installer)

## Installation and Setup

### Install dependencies:
```bash
pip install -r requirements.txt
```

### Alternative: Install in development mode:
```bash
pip install -e .
```

## Running Tests

### Run all tests:
```bash
pytest
```

### Run with coverage:
```bash
pytest --cov=gilded_rose
```

### Run specific test:
```bash
pytest test_gilded_rose.py::TestGildedRose::test_intro_test
```

## Mutation Testing with mutmut

This project is configured to use `mutmut` for mutation testing.

### Setup mutmut

mutmut is already included in requirements.txt, so it will be installed when you run:
```bash
pip install -r requirements.txt
```

### Run mutation testing:
```bash
mutmut run
```

### Generate HTML report:
```bash
mutmut html
```

### Show results:
```bash
mutmut results
```

### Common mutmut options:
```bash
# Run with verbose output
mutmut run --verbose

# Apply a specific mutant (for debugging)
mutmut apply 1

# Check the status of mutation testing
mutmut results
```

The mutation test results will be available as HTML reports in the `html/` directory.

## Project Structure

- `gilded_rose.py` - Main module containing Item and GildedRose classes
- `test_gilded_rose.py` - Unit tests using pytest
- `requirements.txt` - Python dependencies
- `setup.py` - Package configuration
- `mutmut.ini` - Mutation testing configuration

## Notes

This implementation maintains the same behavior and structure as the Java and .NET versions, including:
- All the complex business logic with nested conditions
- The same method names (adapted to Python naming conventions)
- The same intentional bugs and TODO comments
- The same test that currently fails (expecting "0, 0" but getting "4, 9")

The failing test is intentional and part of the kata's characterization testing approach.

## Usage Example

```python
from gilded_rose import Item, GildedRose

# Create some items
items = [
    Item("Regular Item", 10, 20),
    Item("Aged Brie", 5, 10),
    Item("Sulfuras, Hand of Ragnaros", 0, 80),
    Item("Backstage passes to a TAFKAL80ETC concert", 15, 20)
]

# Create GildedRose instance
app = GildedRose(items)

# Process items (update quality and sell_in)
app.process()

# Print results
for item in items:
    print(item)
```