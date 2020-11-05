from typing import Set

from slugify import slugify


ALL_TAGS: Set['Tag'] = set()


class Tag:
    """A tag for articles."""
    def __init__(self, name: str):
        self.name: str = name
        self.slug = slugify(name, lower=False)
        ALL_TAGS.add(self)


    def __hash__(self) -> int:
        """Return a case-insensitive hash for this tag."""
        return self.name.lower().__hash__()


    @property
    def url(self) -> str:
        """Return the url for this tag."""
        return f"/tags/{self.slug}/page_0.html"
