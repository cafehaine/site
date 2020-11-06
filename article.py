"""
A container for the articles.
"""

from datetime import datetime, timezone
import re
from typing import Iterable, List, Set

from bs4 import BeautifulSoup
import markdown
from slugify import slugify

from tag import register_tags, Tag

SLUG_BLACKLIST = ("tags", "browse")

ALL_ARTICLES: Set['Article'] = set()

class Article:
    """A container for atricles."""
    def __init__(self, path: str):
        self.date: datetime
        self._tags: Set[Tag]
        self.title: str
        self.slug: str
        self.draft: bool = False

        with open(path, 'r') as article:
            while (line := article.readline().strip()) != "---":
                self._parse_property(line)
            self.contents = article.read()

        if not self.draft:
            ALL_ARTICLES.add(self)
            register_tags(self._tags)


    @property
    def tags(self) -> List[Tag]:
        """Return a sorted list of this article's tags."""
        output = list(self._tags)
        output.sort(key=lambda t: t.name.lower())
        return output


    def similar_articles(self) -> Iterable[str]:
        """Return 3 similar articles (based on the number of common tags)."""
        similar_articles = list(ALL_ARTICLES)
        similar_articles.remove(self)

        # Sort in alphabetical order first
        similar_articles.sort(key=lambda art: art.title)

        # Sort by number of common tags
        similar_articles.sort(key= lambda art: len(art._tags & self._tags), reverse=True)

        return similar_articles[:3]


    def render(self) -> str:
        """Render this article's markdown."""
        return markdown.markdown(self.contents, output_format="html5", extensions=['md_in_html'])


    def excerpt(self) -> str:
        """Return the beginning of this article (without html)."""
        # Get article "raw" text
        full_render = self.render()
        soup = BeautifulSoup(full_render, features="html.parser")
        text = soup.get_text().strip()
        text = re.sub("(\s|\r?\n)", " ", text)

        # Extract around 120 chars
        match = re.match("^(?P<text>.{,120})(?:\s|$)", text)
        output = match['text']
        if not output.endswith(("?","…","!",".")):
            output += "…"

        return output


    @property
    def url(self) -> str:
        """Return the url for this article."""
        return f"/articles/{self.slug}/"


    def _parse_property(self, line: str):
        """Parse a single property line."""
        key, value = line.split(sep=":", maxsplit=1)
        key = key.strip()
        value = value.strip()
        if key == "date":
            self.date = datetime.fromisoformat(value)
            self.date = self.date.astimezone(timezone.utc)
        elif key == "title":
            self.title = value
            self.slug = slugify(value, lower=False)
            if self.slug in SLUG_BLACKLIST:
                raise ValueError(f"Change the title for {title}.")
        elif key == "tags":
            self._tags = set(Tag(name) for name in value.split(sep=","))
        elif key == "draft":
            self.draft = value == "yes"
        else:
            raise ValueError(f"Unknown property: {key}.")
