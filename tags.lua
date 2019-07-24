local t = {
	csharp= "C#",
	modernui= "Modern UI",
	TEST= "TEST",
}

local meta = {}

-- Auto capitalize if not special case
function meta.__index(table, key)
	return key:sub(1,1):upper()..key:sub(2):lower()
end

return setmetatable(t, meta)
