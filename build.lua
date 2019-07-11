local marccup = require('marccup')
local art = require('article')

local posix_mkdir = require('posix').mkdir
local glob_glob = require('posix.glob').glob
local stat_S_ISDIR = require('posix.sys.stat').S_ISDIR
local stat_lstat = require('posix.sys.stat').lstat
local dirent_files = require('posix.dirent').files
local unistd_unlink = require('posix.unistd').unlink
local unistd_rmdir = require('posix.unistd').rmdir

-------------------------
-- Clean previous data --
-------------------------

--- Remove recursively path
local function rmr(path)
	for file in dirent_files(path) do
		if file ~= "." and file ~= ".." then
			local name = path.."/"..file
			print(name)
			local stat = stat_lstat(name)
			if stat_S_ISDIR(stat.st_mode) ~= 0 then
				rmr(name)
				unistd_rmdir(name)
			else
				unistd_unlink(name)
			end
		end
	end
end

rmr("out")
posix_mkdir("out")

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
