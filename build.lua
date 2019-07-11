local marccup = require('marccup')
local art = require('article')
local glob_glob = require('posix.glob').glob
local tmpl = require('tmpl')

-------------------------
-- Clean previous data --
-------------------------

os.execute("rm -r out")
os.execute("mkdir out")
os.execute("cp -r static/* out")
os.execute("mkdir out/blog")

----------
-- Main --
----------

local article_meta_files = glob_glob("articles/*.lua", 0) or {}
local articles = {}

for i,v in ipairs(article_meta_files) do
	local name = v:match("^(.*/.*)%.lua$")
	articles[i] = art.new(name)
end

---------------
-- Rendering --
---------------

local template_blog = io.open("template_blog.html")
local blog_renderer = tmpl(template_blog:read("*a"))
template_blog:close()
for i=1, #articles do
	local ctx = {
		article = articles[i]
	}
	print(articles[i].name)
	local out = io.open("out/blog/"..articles[i].name..".html","w")
	for s in blog_renderer(ctx) do
		out:write(s)
	end
	out:close()
end
