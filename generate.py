"""
Generate my static site.
"""
import datetime
import glob
from os import makedirs
import shutil
from typing import Collection, List

from jinja2 import Environment, PackageLoader, select_autoescape
import markdown

from article import Article
from tag import ALL_TAGS

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
            autoescape=select_autoescape(['html', 'xml']),
    )
    env.globals['year'] = datetime.date.today().year
    article_template = env.get_template("article.html")

    # Cleanup output directory
    try:
        shutil.rmtree("out")
    except FileNotFoundError:
        pass

    # Find articles and load them
    articles: List[Article] = []

    for path in glob.iglob("./content/*.md"):
        print(f"Loading article at path '{path}'.")
        article = Article(path)
        articles.append(article)

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
    print(f"Generating tag page index.")
    # TODO

    for tag in ALL_TAGS:
        pass # TODO generate pagination for each tag

    # copy static assets
    shutil.copytree("static/", "out/", dirs_exist_ok=True)


if __name__ == "__main__":
    main()
