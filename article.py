"""
A container for the articles.
"""

from datetime import date
from typing import List

import markdown
from slugify import slugify

class Article:
    """A container for atricles."""
    def __init__(self, path: str):
        self.date: date
        self.tags: List[str]
        self.title: str
        self.slug: str

        with open(path, 'r') as article:
            while (line := article.readline().strip()) != "---":
                self._parse_property(line)
            self.contents = article.read()


    def render(self) -> str:
        """Render this article's markdown."""
        return markdown.markdown(self.contents)


    def _parse_property(self, line: str):
        """Parse a single property line."""
        key, value = line.split(sep=":", maxsplit=1)
        key = key.strip()
        value = value.strip()
        if key == "date":
            self.date = date.fromisoformat(value)
        elif key == "title":
            self.title = value
            self.slug = slugify(value, lower=False)
        elif key == "tags":
            self.tags = value.split(sep=",")
        else:
            raise ValueError(f"Unknown property: {key}.")
