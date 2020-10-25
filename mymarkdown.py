"""
This module implements the MyMarkdown custom parser, used to parse the markdown
in my articles and pages.

This is in some sense an incompatible alternative to Markdown, as it supports
some new tags, while removing support for other.

Some notable changes are the following:
- no support for nested lists
- list elements are on a single line
- preformated blocks must specify a language (python, bash, html, text...)
"""
from datetime import date
import re
from typing import Dict, Optional


TOKENS: Dict[str, str] = {
    "document_property": r"#~.*(?:\n|$)",
    "unordered_list": r"- .*(?:\n|$)",
    "ordered_list": r"\d+\..*(?:\n|$)",
    "title": r"#[^~].*(?:\n|$)",
    "code_block_start": r"```.+\n",
    "code_block_end": r"```(?:\n|$)",
    "link": r"\[[^\[\]]+\]\([^()]+\)",
    "image": r"!\[[^\[\]]+\]\([^()]+\)",
    # TODO table stuff, maybe
}


def _generate_regex() -> re.Pattern:
    """Generate the tokeniser regex from the TOKENS dict."""
    tokens = []

    for name, pattern in TOKENS.items():
        tokens.append(f"(?P<{name}>{pattern})")

    return re.compile("|".join(tokens))


RE_TOKENISER: re.Pattern = _generate_regex()


class MyMarkdown:
    """A custom markdown parser that splits a document based on titles (H2s)."""

    def __init__(self, filepath: str) -> None:
        self.sections = []
        self.title: str
        self.date: date
        self.tags = []

    def _parse_document(self, document: str) -> None:
        """Parse the markdown document and fill this instance's sections."""
        while document:
            # TODO
            raise NotImplementedError("Todo.")
