"""
A container for the articles.
"""

from datetime import date
from typing import Iterable, Set

import markdown
from slugify import slugify

from tag import Tag

SLUG_BLACKLIST = ("tags", "browse")

ALL_ARTICLES: Set['Article'] = set()

class Article:
    """A container for atricles."""
    def __init__(self, path: str):
        self.date: date
        self.tags: Set[Tag]
        self.title: str
        self.slug: str

        with open(path, 'r') as article:
            while (line := article.readline().strip()) != "---":
                self._parse_property(line)
            self.contents = article.read()

        ALL_ARTICLES.add(self)


    def similar_articles(self) -> Iterable[str]:
        """Return 3 similar articles (based on the number of common tags)."""
        similar_articles = list(ALL_ARTICLES)
        similar_articles.remove(self)

        # Sort in alphabetical order first
        similar_articles.sort(key=lambda art: art.title)

        # Sort by number of common tags
        similar_articles.sort(key= lambda art: len(art.tags & self.tags), reverse=True)

        return similar_articles[:3]


    def render(self) -> str:
        """Render this article's markdown."""
        return markdown.markdown(self.contents, output_format="html5", extensions=['md_in_html'])


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
            if self.slug in SLUG_BLACKLIST:
                raise ValueError(f"Change the title for {title}.")
        elif key == "tags":
            self.tags = set(Tag(name) for name in value.split(sep=","))
        else:
            raise ValueError(f"Unknown property: {key}.")
