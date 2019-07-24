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
	local file = io.open(name..".html")
	local renderer = tmpl(file:read("*a"))
	file:close()
	return renderer
end

local function render_template(output, renderer, context)
	local out = io.open(output, "w")
	for s in renderer(context) do
		out:write(s)
	end
	out:close()
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

print("=> Blog")
os.execute("mkdir out/blog")

print("  - Articles")
local blog_renderer = load_template("template_blog")
for i=1, #articles do
	local ctx = {
		article = articles[i]
	}
	print("    - "..articles[i].name)
        os.execute("mkdir out/blog/'"..articles[i].name.."'")
	render_template("out/blog/"..articles[i].name.."/index.html", blog_renderer, ctx)
end

print("  - By date")
print("  - By tags")
print("    - Tag list")
local tags_renderer = load_template("template_tags")
local ctx = {tags={{url_name="linux", name="Linux"}, {url_name="csharp", name="C#"}}}
os.execute("mkdir out/blog/tags")
render_template("out/blog/tags/index.html", tags_renderer, ctx)
print("    - Tag pages")

