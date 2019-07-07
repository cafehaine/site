local glob = require('posix.glob')
local marccup = require('marccup')

local function up_to_100_chars(string)
	return string:sub(1,100):match("^(.*)%s.-$").."…"
end

-------------------
-- Article class --
-------------------

local art = {}
art.__index = art
art._all_articles = {}

function art.new(metadata, content)
	local self = setmetatable({}, art)

	for k,v in pairs(metadata) do
		self[k] = v
	end

	self.content = content
	self.excerpt = up_to_100_chars(marccup.only_text(content))

	art._all_articles[#art._all_articles+1] = self

	return self
end

function art:tags_in_common(article)
	local common = 0
	for _,t in ipairs(self.tags) do
		for _,t2 in ipairs(article.tags) do
			if t2 == t then
				common = common + 1
				break
			end
		end
	end
	return common
end

local function comp_first_index(t1, t2)
	return t1[1] < t2[1]
end

function art:similar_articles()
	local output = {}
	for _,article in ipairs(art._all_articles) do
		if article ~= self then
			local common = self:tags_in_common(article)
			if common > 0 then
				output[#output+1] = {common, article}
			end
		end
	end
	table.sort(output, comp_first_index)
	return output
end

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
