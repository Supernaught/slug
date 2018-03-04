function p(...)
	print(...)
end

function tp(...)
	if type(...) == 'table' then
		tlog.print(...)
	else
		p(...)
	end
end

-- Get the list of files in the folder
-- file_list is the array to put the list of files
function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.isFile(file) then
            table.insert(file_list, file)
        elseif love.filesystem.isDirectory(file) then
            recursiveEnumerate(file, file_list)
        end
    end
end

-- Require Files (duh)
function requireFiles(files)
    for i, file in ipairs(files) do
        if file:sub(-4) == '.lua' then
            local filepath = file:sub(1, -5)
            local parts = _.split(filepath, "/")
            local class = parts[#parts]
            local status, path = pcall(require, filepath)
            p(filepath, status)
            if status then
                _G[class] = require(filepath)
            end
        end
    end
end

function rectangleContains(x1, y1, w1, h1, x2, y2, w2, h2)
  return x2 >= x1 and x2 + w2 <= x1 + w1 and
         y2 >= y1 and y2 + h2 <= y1 + h1
end