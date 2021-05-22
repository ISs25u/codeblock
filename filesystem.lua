codeblock.filesystem = {}

function codeblock.filesystem.get_files(directory_path)
    return minetest.get_dir_list(directory_path)
end

function codeblock.filesystem.read(file)
    local file = io.open(file, "rb")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

function codeblock.filesystem.write(filepath, content)
    minetest.safe_file_write(filepath, content)
    return content
end
