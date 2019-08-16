local marccup = require('marccup')
local tags = require('tags')

local function up_to_100_chars(string)
	return string:sub(1,100):match("^(.*)%s.-$").."…"
end

local months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
}

local art = {}
art.__index = art
art._all_articles = {}
art._all_tags = {}

-----------
-- Utils --
-----------

local function shallow_copy_table(t)
	local output = {}
	for k,v in pairs(t) do
		output[k] = v
	end
	return output
end

-- Some functions for table sorting

local function comp_name(t1, t2)
	return t1.name < t2.name
end

local function comp_first_index(t1, t2)
	return t1[1] < t2[1]
end

local function desc_date(t1, t2)
	if t1.year_num == t2.year_num then
		if t1.month_num == t2.month_num then
			if t1.day_num == t2.day_num then
				return t1.title < t2.title
			end
			return t1.day_num > t2.day_num
		end
		return t1.month_num > t2.month_num
	end
	return t1.year_num > t2.year_num
end

function art.get_tag_list()
	local output = {}
	for tag,_ in pairs(art._all_tags) do
		output[#output+1] = {url_name=tag, name=tags[tag]}
	end
	table.sort(output, comp_name)
	return output
end

function art.articles_with_tag(tag)
	local output = {}
	for _,article in ipairs(art._all_articles) do
		if article:has_tag(tag) then
			output[#output+1] = article
		end
	end
	table.sort(output, desc_date)
	return output
end

function art.all_articles()
	local articles = shallow_copy_table(art._all_articles)
	table.sort(articles, desc_date)
	return articles
end

function art.new(name)
	local self = setmetatable(dofile(name..".lua"), art)

	if self.wip then return nil end

	for _,tag in ipairs(self.tags) do
		art._all_tags[tag] = true
	end

	self.name = name:match("^.*/(.*)$")
	self.content = marccup.to_tree(io.open(name..".cup"))

	local d,m,y = self.date:match("(.*)/(.*)/(.*)")
	self.day = d
	self.day_num = tonumber(d)
	self.month = months[tonumber(m)]
	self.month_num = tonumber(m)
	self.year = y
	self.year_num = tonumber(y)

	self.excerpt = up_to_100_chars(marccup.only_text(self.content))

	self.body = self:render_body()
	self.tag_list = self:render_tag_list()

	art._all_articles[#art._all_articles+1] = self

	return self
end

function art:has_tag(tag)
	-- handle the "build.lua tags" and the "real" tags
	if type(tag) == "table" then
		tag = tag.url_name
	end
	for _,t in ipairs(self.tags) do
		if t == tag then
			return true
		end
	end
	return false
end

function art:tags_in_common(article)
	local common = 0
	for _,t in ipairs(self.tags) do
		if article:has_tag(t) then
			common = common + 1
			break
		end
	end
	return common
end

function art:similar_articles()
	local similar = {}
	for _,article in ipairs(art._all_articles) do
		if article ~= self then
			local common = self:tags_in_common(article)
			if common > 0 then
				similar[#similar+1] = {common, article}
			end
		end
	end
	table.sort(similar, comp_first_index)
	local output = {}
	for i,v in ipairs(similar) do
		output[i] = v[2]
	end
	return output
end

local xml_entities = "['\"<>&]"

local xml_escape = {
    ["&"]="&amp;",
    [">"]="&gt;",
    ["<"]="&lt;",
    ['"']="&quot;",
    ["'"]="&apos;",
}

local function escape(text)
	return text:gsub(xml_entities, xml_escape)
end

local pp = require('prettyprint').print

local function render_text(text)
	local output = {}
	for _,node in ipairs(text) do
		if type(node) == "string" then
			output[#output+1] = escape(node)
		elseif node.type == "link" then
			output[#output+1] = ('<a href="%s">%s</a>'):format(node.url, escape(node.description))
		elseif node.type == "inline_code" then
			output[#output+1] = ("<code class='inline-code'>%s</code>"):format(escape(node.body))
		else
			pp(node, true)
		end
	end
	return table.concat(output)
end

local function render_code(code)
	local output = {'<div class="code-block">', '<div class="lines">'}
	_, lines = code.body:gsub("\n","")
	for i=code.start, code.start+lines do
		output[#output+1] = "<span>"..i.."</span>"
	end
	output[#output+1] = "</div>"

	local temp_name = os.tmpname()
	local temp_file = io.open(temp_name, "w")
	temp_file:write(code.body)
	temp_file:close()
	lexer = code.lang or "text"
	local pygmentize = io.popen("pygmentize -l "..lexer.." -f html "..temp_name)
	output[#output+1] = pygmentize:read("a")
	pygmentize:close()
	os.remove(temp_name)

	output[#output+1] = "</div>"
	return table.concat(output)
end

function art:render_body()
	local output = {}
	local first_title = true
	for _,node in ipairs(self.content) do
		if node.type == "title" then
			if node.level == 1 then
				if not first_title then
					output[#output+1] = "</section>"
				else
					first_title = false
				end
				output[#output+1] = "<section>"
			end
			output[#output+1] = ("<h%d>%s</h%d>"):format(node.level + 1, escape(node.body), node.level + 1)
		elseif node.type == "text" then
		        output[#output+1] = "<p>"
			output[#output+1] = render_text(node.data)
		        output[#output+1] = "</p>"
		elseif node.type == "code" then
			output[#output+1] = render_code(node)
		end
	end
	output[#output+1] = "</section>"
	return table.concat(output)
end

function art:render_tag_list()
	local output = {}
	for _,t in ipairs(self.tags) do
		output[#output+1] = ('<a href="/blog/tags/%s/page_0.html">%s</a>'):format(t, tags[t])
	end
	return table.concat(output, " ")
end

return art
