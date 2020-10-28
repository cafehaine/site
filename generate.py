"""
Generate my static site.
"""
import glob
from os import makedirs
from shutil import rmtree
from typing import Collection, List

from jinja2 import Environment, PackageLoader, select_autoescape
import markdown

from article import Article

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
    env = Environment(
            loader=PackageLoader('generate', 'templates'),
            autoescape=select_autoescape(['html', 'xml'])
    )
    article_template = env.get_template("article.html")

    # Cleanup output directory
    try:
        rmtree("out")
    except FileNotFoundError:
        pass

    # Find articles and load them
    articles: List[str] = []

    for path in glob.iglob("./content/*.md"):
        print(f"Loading article at path '{path}'.")
        articles.append(Article(path))

    articles.sort(key=lambda art: art.date)

    # generate a page for each article
    for article in articles:
        print(f"Generating page for {article.title}.")
        makedirs(f"out/articles/{article.slug}/")
        with open(f"out/articles/{article.slug}/index.html", 'w') as out:
            out.write(article_template.render(article=article))

    # generate an index page
    print("Generating the index page.")
    # TODO

    # generate a chronological pagination
    for index, page_articles in enumerate(paginate_by_n(articles, ARTICLES_PER_PAGE)):
        print(f"Generating page {index} of the article list.")
        # TODO

    # generate a tag based pagination
    tags = set(tag for article in articles for tag in article.tags)
    print(f"Generating tag page index.")
    # TODO

    for tag in tags:
        pass # TODO generate pagination for each tag

    # copy static assets


if __name__ == "__main__":
    main()
