local glob = require('posix.glob')
local marccup = require('marccup')
local art = require('article')

----------
-- Main --
----------

local article_meta_files = glob.glob("articles/*.lua", 0) or {}
local articles = {}

for i,v in ipairs(article_meta_files) do
	local metadata = dofile(v)
	local content_path = v:match("^(.*/.*)%.lua")..".cup"
	local document_tree = marccup.to_tree(io.open(content_path))
	articles[i] = art.new(metadata, document_tree)
end
--[[
for i=1, #articles do
	print(articles[i].title)
	print()
	print("Excerpt:")
	print(articles[i].excerpt)
	print()
	print("Tags:")
	print(table.concat(articles[i].tags, ", "))
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
]]
articles[3]:render_body()
