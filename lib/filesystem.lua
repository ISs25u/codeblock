codeblock.filesystem = {}

-------------------------------------------------------------------------------
-- local
-------------------------------------------------------------------------------

local get_dir_list = minetest.get_dir_list
local safe_file_write = minetest.safe_file_write

-------------------------------------------------------------------------------
-- private
-------------------------------------------------------------------------------

local function get_files(dirpath)
    if not dirpath then return false, "Missing argument <path>" end
    if type(dirpath) ~= 'string' then return "<path> must be a string" end
    local dirs = get_dir_list(dirpath)
    table.sort(dirs)
    return dirs
end

local function get_file_from_index(dirpath, index)
    if not index then return false, "Missing argument <index>" end
    if type(index) ~= 'number' then return false, "<index> must be a number" end
    local dirs, err = get_files(dirpath)
    if err then return false, err end
    local file = dirs[index]
    if not file then return false, "No file found" end
    return file
end

local function read(filepath)
    local file, err = io.open(filepath, "rb")
    if not file then return false, err end
    local content = file:read("*a")
    file:close()
    return content
end

local function write(filepath, content) return
    safe_file_write(filepath, content) end

-------------------------------------------------------------------------------
-- export
-------------------------------------------------------------------------------

codeblock.filesystem.get_files = get_files
codeblock.filesystem.get_file_from_index = get_file_from_index
codeblock.filesystem.read = read
codeblock.filesystem.write = write
