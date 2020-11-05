from typing import Set

from slugify import slugify


ALL_TAGS: Set['Tag'] = set()


def register_tags(tags: Set['Tag']):
    """Register the given tags in ALL_TAGS"""
    ALL_TAGS.update(tags)


class Tag:
    """A tag for articles."""
    def __init__(self, name: str):
        self.name: str = name
        self.slug = slugify(name, lower=False)


    def __hash__(self) -> int:
        """Return a case-insensitive hash for this tag."""
        return self.name.lower().__hash__()


    def __eq__(self, other) -> bool:
        """Return if two tags are the same."""
        return self.name.lower() == other.name.lower()


    @property
    def url(self) -> str:
        """Return the url for this tag."""
        return f"/tags/{self.slug}/page_0.html"
