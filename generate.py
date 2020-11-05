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

from article import Article, ALL_ARTICLES
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
    # Setup jinja
    env = Environment(
            loader=PackageLoader('generate', 'templates'),
            autoescape=select_autoescape(['html', 'xml']),
            extensions=['jinja2.ext.debug'],
    )
    env.globals['year'] = datetime.date.today().year

    # Load templates
    article_template = env.get_template("article.html")
    index_template = env.get_template("index.html")
    tag_index_template = env.get_template("tags.html")
    page_template = env.get_template("page.html")

    # Cleanup output directory
    try:
        shutil.rmtree("out")
    except FileNotFoundError:
        print("out not found.")
        pass

    # Find articles and load them
    articles: List[Article] = []

    for path in glob.iglob("./content/*.md"):
        print(f"Loading article at path '{path}'.")
        article = Article(path)
        articles.append(article)

    articles = list(ALL_ARTICLES)
    articles.sort(key=lambda art: art.date, reverse=True)

    # generate a page for each article
    for article in articles:
        print(f"Generating page for {article.title}.")
        makedirs(f"out/articles/{article.slug}/")
        with open(f"out/articles/{article.slug}/index.html", 'w') as out:
            out.write(article_template.render(article=article, nav="blog"))

    # generate an index page
    print("Generating the index page.")
    latest_articles = articles[:3]
    with open(f"out/index.html", 'w') as out:
        out.write(index_template.render(latest_articles=latest_articles))

    # generate a chronological pagination
    for index, page_articles in enumerate(paginate_by_n(articles, ARTICLES_PER_PAGE)):
        print(f"Generating page {index} of the article list.")
        with open(f"out/articles/page_{index}.html", "w") as out:
            out.write(page_template.render(articles=page_articles, title=f"Index page {index}", nav="blog"))

    # generate a tag based pagination
    print(f"Generating tag page index.")
    sorted_tags = list(ALL_TAGS)
    sorted_tags.sort(key=lambda t: t.name.lower())
    makedirs(f"out/tags/")
    with open(f"out/tags/index.html", 'w') as out:
        out.write(tag_index_template.render(tags=sorted_tags, nav="blog"))

    for tag in ALL_TAGS:
        tag_articles = [article for article in articles if tag in article._tags]
        for index, page_articles in enumerate(paginate_by_n(tag_articles, ARTICLES_PER_PAGE)):
            makedirs(f"out/tags/{tag.slug}")
            print(f"Generating page {index} of the article list for tag {tag.name}.")
            with open(f"out/tags/{tag.slug}/page_{index}.html", "w") as out:
                out.write(page_template.render(articles=page_articles, title=f"Index page {index} for tag {tag.name}", nav="blog"))

    # copy static assets
    shutil.copytree("static/", "out/", dirs_exist_ok=True)


if __name__ == "__main__":
    main()
