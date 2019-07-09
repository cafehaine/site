local marccup = require('marccup')

local function up_to_100_chars(string)
	return string:sub(1,100):match("^(.*)%s.-$").."…"
end

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
			output[#output+1] = ("<pre class='inline-code'>%s</pre>"):format(escape(node.body))
		else
			pp(node, true)
		end
	end
	return table.concat(output)
end

function art:render_body()
	local output = {}
	for _,node in ipairs(self.content) do
		if node.type == "title" then
			output[#output+1] = ("<h%d>%s</h%d>"):format(node.level, escape(node.body), node.level)
		else
		        output[#output+1] = "<p>"
			output[#output+1] = render_text(node.data)
		        output[#output+1] = "</p>"
		end
	end
	print(table.concat(output,"\n"))
end

return art
