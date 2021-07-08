codeblock.filesystem = {}

function codeblock.filesystem.get_files(path)
    if not path then return false, "Missing argument <path>" end
    if type(path) ~= 'string' then return "<path> must be a string" end
    local dirs = minetest.get_dir_list(path)
    table.sort(dirs)
    return dirs
end

function codeblock.filesystem.get_file_from_index(path, index)
    if not index then return false, "Missing argument <index>" end
    if type(index) ~= 'number' then return false, "<index> must be a number" end
    local dirs, err = codeblock.filesystem.get_files(path)
    if err then return false, err end
    local file = dirs[index]
    if not file then return false, "No file found" end
    return file
end

function codeblock.filesystem.read(file)
    local file, err = io.open(file, "rb")
    if not file then return false, err end
    local content = file:read("*a")
    file:close()
    return content
end

function codeblock.filesystem.write(filepath, content)
    return minetest.safe_file_write(filepath, content)
end
