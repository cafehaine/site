"""
Generate my static site.
"""
import glob
from typing import Collection, List

from mymarkdown import MyMarkdown

ARTICLES_PER_PAGE = 10


def paginate_by_n(collection: Collection, n: int) -> List[List]:
    """Split an iterable in a list of lists of n elements."""
    output = []
    current = []
    for elm in collection:
        if len(current) == n:
            output.append(current)
            current = []
        current.append(elm)

    if current:
        output.append(current)

    return output


def main():
    """Generate the site from the articles."""
    # Find articles and load them
    articles: List[MyMarkdown] = []

    for path in glob.iglob("./content/*.md"):
        print(f"Loading article at path '{path}'.")
        articles.append(MyMarkdown(path))

    articles.sort(key=lambda art: art.date)

    # generate a page for each article
    for article in articles:
        print(f"Generating page for {article.title}.")
        # TODO

    # generate an index page
    print("Generating the index page.")
    # TODO

    # generate a chronological pagination
    for index, page_articles in enumerate(paginate_by_n(articles, ARTICLES_PER_PAGE)):
        print(f"Generating page {index} of the article list.")
        # TODO

    # generate a tag based pagination
    # copy static assets


if __name__ == "__main__":
    main()
