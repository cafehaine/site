local marccup = require('marccup')
local art = require('article')
local glob_glob = require('posix.glob').glob
local tmpl = require('tmpl')

-------------------------
-- Clean previous data --
-------------------------

print("=> Cleaning previous build")
os.execute("rm -r out")
os.execute("mkdir out")

print("=> Copying static files")
os.execute("cp -r static/* out")

-----------
-- Utils --
-----------

local function load_template(name)
	local file = io.open("templates/"..name..".html")
	local renderer = tmpl(file:read("*a"))
	file:close()
	return renderer
end

local __nav_template = load_template("nav")
local __footer_template = load_template("footer")

local function render_template(output, renderer, context)
	local out = io.open(output, "w")
	context.nav = __nav_template
	context.footer = __footer_template
	for s in renderer(context) do
		out:write(s)
	end
	out:close()
end

local function generate_date_pages()
	os.execute("mkdir out/blog/all")
	local articles = art.all_articles()
	local renderer = load_template("page")
	local ctx = {articles=articles, title="Articles by date"}
	render_template("out/blog/all/page_0.html", renderer, ctx)
	--TODO handle multiple pages
end

local function generate_tag_pages(tag)
	os.execute("mkdir out/blog/tags/"..tag.url_name)
	local articles = art.articles_with_tag(tag.url_name)
	local renderer = load_template("page")
	local ctx = {articles=articles, title="Articles matching "..tag.name}
	render_template("out/blog/tags/"..tag.url_name.."/page_0.html", renderer, ctx)
	--TODO handle multiple pages
end

-------------------
-- Load articles --
-------------------

local article_meta_files = glob_glob("articles/*.lua", 0) or {}
local articles = {}

for i,v in ipairs(article_meta_files) do
	local name = v:match("^(.*/.*)%.lua$")
	articles[i] = art.new(name)
end

---------------
-- Rendering --
---------------

print("=> Index")
local index_renderer = load_template("index")
latest_articles = art.all_articles()
render_template("out/index.html", index_renderer, {latest_articles})

print("=> Blog")
os.execute("mkdir out/blog")

print("  - Articles")
local blog_renderer = load_template("blog")
for i=1, #articles do
	local ctx = {
		article = articles[i],
		similar_arts = articles[i]:similar_articles()
	}
	print("    - "..articles[i].name)
        os.execute("mkdir out/blog/'"..articles[i].name.."'")
	render_template("out/blog/"..articles[i].name.."/index.html", blog_renderer, ctx)
end

print("  - By date")
generate_date_pages()

print("  - By tags")
print("    - Tag list")
local tags_renderer = load_template("tags")
local ctx = {tags=art.get_tag_list()}
os.execute("mkdir out/blog/tags")
render_template("out/blog/tags/index.html", tags_renderer, ctx)
print("    - Tag pages")
for _,tag in ipairs(art.get_tag_list()) do
	generate_tag_pages(tag)
end

print("  - RSS")
