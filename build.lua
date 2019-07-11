local marccup = require('marccup')
local art = require('article')
local glob_glob = require('posix.glob').glob

-------------------------
-- Clean previous data --
-------------------------

os.execute("rm -r out")
os.execute("mkdir out")
os.execute("cp -r static/* out")

----------
-- Main --
----------

local article_meta_files = glob_glob("articles/*.lua", 0) or {}
local articles = {}

for i,v in ipairs(article_meta_files) do
	local metadata = dofile(v)
	local content_path = v:match("^(.*/.*)%.lua")..".cup"
	local document_tree = marccup.to_tree(io.open(content_path))
	articles[i] = art.new(metadata, document_tree)
end

for i=1, #articles do
	print(articles[i].title)
	print()
	print("Excerpt:")
	print(articles[i].excerpt)
	print()
	print("Tags:")
	print(articles[i].tag_list)
	print()
	print("Similar articles:")
	local sim = articles[i]:similar_articles()
	for _,art in ipairs(sim) do
		print(art[1].." "..art[2].title)
	end
	print()
	print("=====================")
	print()
end
