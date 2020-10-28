from typing import Set

from slugify import slugify


ALL_TAGS: Set['Tag'] = set()


class Tag:
    """A tag for articles."""
    def __init__(self, name: str):
        self.name: str = name
        self.slug = slugify(name, lower=False)
        ALL_TAGS.add(self)
