import re
from xml.etree import ElementTree

from markdown.extensions import Extension
from markdown.treeprocessors import Treeprocessor

TITLE_RE = re.compile(r"[hH][1-6]")

class TitleOffsetProcessor(Treeprocessor):
    """
    Offset the title level by some number.

    Useful if the markdown isn't supposed to start at h1 but h3 for example.
    """
    offset = 0

    def run(self, root: ElementTree.ElementTree):
        for elm in root.iter():
            if TITLE_RE.match(elm.tag):
                level = int(elm.tag.lstrip("hH"))
                level += self.offset
                elm.tag = f"h{level}"

class TitleOffset(Extension):
    """An extension to register the TitleOffsettProcessor."""
    def __init__(self, **kwargs):
        self.config = {
            'offset': [0, 'The offset to apply to h[n] elements']
        }
        super().__init__(**kwargs)

    def extendMarkdown(self, md):
        processor = TitleOffsetProcessor(md)
        processor.offset = self.getConfig('offset', 0)
        md.treeprocessors.register(processor, 'titleoffset', 1)
